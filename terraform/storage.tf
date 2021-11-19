# 外部公開しないプライベートバケット
resource "aws_s3_bucket" "private" {
  bucket = "startups-private-bucket" # 一意にする必要あり
  # TODO: aclの追加？

  versioning { # バージョニング : 削除・変更しても以前のマージョンへ復元できる
    enabled = true
  }

  server_side_encryption_configuration { # 暗号化 : 保存時に自動で暗号化、参照時に自動で復号
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "startups-private-bucket"
  }

  force_destroy = true # TODO: 本格運用の際はコメントアウト
}

# ブロックパブリックアクセス
resource "aws_s3_bucket_public_access_block" "private" { # 特に理由が無い場合は、全ての設定を有効に
  bucket = aws_s3_bucket.private.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

# パブリックバケット
resource "aws_s3_bucket" "public" {
  bucket = "startups-public-bucket"
  acl = "public-read" # アクセス権 : インターネットからの読み込み許可

  cors_rule { # Cross-Origin Resource Sharing : 許可するオリジン・メソッド定義
    allowed_origins = ["https://startups-note.com"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
    max_age_seconds = 3000
  }

  force_destroy = true # TODO: 本格運用の際はコメントアウト
}

# ログバケット
resource "aws_s3_bucket" "alb_log" {
  bucket = "startups-alb-lob-bucket"

  lifecycle_rule {
    enabled = true

    expiration {
      # TODO: 本格運用するときは法律に則る。（180days?）
      # NOTE: 現状はファイル増やしたく無いため、5days
      days = "5"
    }
  }

  force_destroy = true # TODO: 本格運用の際はコメントアウト
}

# バケットポリシー（S3バケットへのアクセス権）
resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]

    principals {
      type = "AWS"
      # NOTE: 記述方法変えたら一旦applyできた（https://qiita.com/stakakey/items/ca54f8c7bba6723c7eed）
      identifiers = [data.aws_elb_service_account.main.arn] # 東京リージョン（ap-northeast-1）のELBアカウントID（582318560864）
    }
  }
}

data "aws_elb_service_account" "main" {}