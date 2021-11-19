# App
resource "aws_ecr_repository" "app" {
  name = "startups-app-including-bundler-11180755" # dockerイメージのタグと一致させる

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECRリポジトリに保存できるイメージの数に限りあるため、制限かける
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  # "release"で始まるイメージタグを10個までに制限
  policy = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Keep last 10 release tagged images",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["release"],
            "countType": "imageCountMoreThan",
            "countNumber": 10
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
  EOF
}

# Nginx
resource "aws_ecr_repository" "nginx" {
  name = "startups-nginx-11180755"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "nginx" {
  repository = aws_ecr_repository.nginx.name

  # "release"で始まるイメージタグを10個までに制限
  policy = <<EOF
    {
      "rules": [
        {
          "rulePriority": 1,
          "description": "Keep last 10 release tagged images",
          "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["release"],
            "countType": "imageCountMoreThan",
            "countNumber": 10
          },
          "action": {
            "type": "expire"
          }
        }
      ]
    }
  EOF
}