variable "domain" {}

resource "aws_lb" "startups" {
  name = "startups"
  load_balancer_type = "application" # ALB指定
  internal = false # インターネット向け
  idle_timeout = 60 # タイムアウト（デフォルト60s）
  enable_deletion_protection = false # 削除保護 # TODO: 実際に運用するときは「true」

  subnets = [ # クロスゾーン負荷分散
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id,
  ]

  # 現状S3は利用していない
  access_logs {
    bucket = aws_s3_bucket.alb_log.id
    enabled = true
  }

  # module化したsgを使って定義
  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]
}

# リスナー（どのポートのリクエストを受け付けるか設定）
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.startups.arn
  port = "80"
  protocol = "HTTP" # ALBは「HTTP」「HTTPS」のみサポート

  default_action {
    type = "fixed-response" # 固定のHTTPレスポンスを応答

    fixed_response {
      content_type = "text/plain"
      message_body = "200 HTTP"
      status_code = "200"
    }
  }
}


# Route 53

# Route53でドメイン登録した場合、NS, SOAレコード込みのホストゾーンが自動作成される。そのホストゾーン参照
data "aws_route53_zone" "startups" {
  name = var.domain
}

# DNSレコード定義、設定したドメインでALBとアクセス
resource "aws_route53_record" "startups" {
  zone_id = data.aws_route53_zone.startups.zone_id
  name = data.aws_route53_zone.startups.name
  type = "A" # AWS独自拡張のALIASレコードするため、Aレコード指定

  alias { # DNSからみると、単なるAレコード扱い。ALB, S3バケット, CloudFrontも指定可能
    name = aws_lb.startups.dns_name
    zone_id = aws_lb.startups.zone_id
    evaluate_target_health = true
  }

  # CNAMEレコードの名前解決 : ドメイン名 ⇨ CNAMEレコードのドメイン名 ⇨ IPアドレス
  # ALIASレコードの名前解決 : ドメイン名 ⇨ IPアドレス （パフォーマンス向上）
}

# SSL証明書
resource "aws_acm_certificate" "startups" {
  domain_name = aws_route53_record.startups.name
  subject_alternative_names = [] # ドメイン名の追加可能
  validation_method = "DNS" # ドメインの所有権の検証方法。SSL証明書を自動更新したい場合、DNS検証

  lifecycle {
    create_before_destroy = true

    # SSL証明書の再作成時のサービス影響を最小化
    # 「リソースの削除 ⇨ リソース作成」⇨ 「リソースを作成 ⇨ リソースの削除」に変更
  }
}

# SSL証明書の検証

# 検証用のDNSレコード追加
resource "aws_route53_record" "startups_certificate" {
  # provider 3.0.0 以降は記述が変わる
  # （https://dev.classmethod.jp/articles/terraform-aws-certificate-validation/）
  # （https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation）
  for_each = {
    # domain_nameを、keyとしたmapタイプに変換
    for dvo in aws_acm_certificate.startups.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      type = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  # name = aws_acm_certificate.startups.domain_validation_options[0].resource_record_name
  # type = aws_acm_certificate.startups.domain_validation_options[0].resource_record_type
  # records = [aws_acm_certificate.startups.domain_validation_options[0].resource_record_value]

  name = each.value.name
  type = each.value.type
  records = [each.value.record]
  zone_id = data.aws_route53_zone.startups.id
  ttl = 60
}

# 検証の待機
resource "aws_acm_certificate_validation" "startups" {
  certificate_arn = aws_acm_certificate.startups.arn
  # provider 3.0.0 以降は記述が変わる
  validation_record_fqdns = [for record in aws_route53_record.startups_certificate : record.fqdn]
  # validation_record_fqdns = [aws_route53_record.startups_certificate.fqdn]

  # apply時にSSL証明書の検証が完了するまで待機する
  # 実際に何かのリソースを作るわけではない
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.startups.arn
  port = "443"
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate_validation.startups.certificate_arn # 用意したSSL証明書を指定
  ssl_policy = "ELBSecurityPolicy-2016-08" # セキュリティポリシーの利用指定（推奨）

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "200 HTTPS"
      status_code = "200"
    }
  }
}

# HTTPをHTTPSへリダイレクトする、リダイレクトリスナー
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.startups.arn
  port = "8080"
  protocol = "HTTP"

  default_action {
    type = "redirect" # 別のURLにリダイレクト

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ECSサービスに関連付けるターゲットグループ（ALBがリクエストをフォワードする対象）
resource "aws_lb_target_group" "startups" {
  name = "startups"
  target_type = "ip" # ECS Fargeteでは、「ip」指定
  vpc_id = aws_vpc.startups.id
  port = 80
  protocol = "HTTP" # HTTPSの終端はALBで行うため、HTTPを指定することが多い
  deregistration_delay = 300 # ターゲットの登録を解除する前に、ALBが待機する時間（デフォルト300s）

  health_check {
    path = "/"
    healthy_threshold = 5 # 正常判定を行うまでのヘルスチェック実行回数
    unhealthy_threshold = 2 # 異常判定を行うまでのヘルスチェック実行回数
    timeout = 5 # ヘルスチェックのタイムアウト時間
    interval = 30 # ヘルスチェックの実行間隔
    matcher = 200 # 正常判定を行うために使用するHTTPステータスコード
    port = "traffic-port" # ヘルスチェック時に使用するプロトコル。「traffic-port」⇨ 指定したportを使用
    protocol = "HTTP"
  }

  depends_on = [aws_lb.startups] # ALBとターゲットグループを、ECSサービスと同時に作成するとエラーになるため、依存関係を制御するワークアラウンドを追加
}

# ターゲットグループにリクエストをフォワードするリスナールール
resource "aws_lb_listener_rule" "startups" {
  listener_arn = aws_lb_listener.https.arn
  priority = 100 # リスナールールの優先順位。小さいほど優先度高い。デフォルトルールはもっとも優先度低い

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.startups.arn
  }

  condition {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule#example-usage
    path_pattern {
      values = ["/*"]
    }

    # field = "path-pattern"
    # values = ["/*"]
  }
}

output "alb_dns_name" {
  value = aws_lb.startups.dns_name
}

output "domain_name" {
  value = aws_route53_record.startups.name
}