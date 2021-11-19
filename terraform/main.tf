data "aws_iam_policy_document" "allow_describe_regions" {
  statement {
    effect = "Allow" # 許可
    actions = ["ec2:DescribeRegions"] # リージョン一覧取得
    resources = ["*"] # 全てのリソース
  }
}

# IAMロール
module "describe_regions_for_ecs" {
  source ="./iam_role"
  name = "startups-describe-regions-for-ec2"
  identifier = "ec2.amazonaws.com"
  policy = data.aws_iam_policy_document.allow_describe_regions.json
}

# ALB用のセキュリティグループ
module "http_sg" {
  source = "./security_group"
  name = "startups-http-sg"
  vpc_id = aws_vpc.startups.id
  port = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source = "./security_group"
  name = "startups-https-sg"
  vpc_id = aws_vpc.startups.id
  port = 443
  cidr_blocks = ["0.0.0.0/0"]
}

module "http_redirect_sg" {
  source = "./security_group"
  name = "startups-http-redirect-sg"
  vpc_id = aws_vpc.startups.id
  port = 8080
  cidr_blocks = ["0.0.0.0/0"]
}

