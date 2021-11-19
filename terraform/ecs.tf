resource "aws_ecs_cluster" "startups" {
  name = "startups-cluster"
}

resource "aws_ecs_task_definition" "startups_app_nginx" {
  family = "startups-app" # タスク定義名のプレフィックス
  cpu = "256"
  memory = "512"
  network_mode = "awsvpc" # Fargate起動タイプの場合、awsvpc
  requires_compatibilities = ["FARGATE"]

  container_definitions = file("./app_task_definition.json")
  # container_definitions = file("./container_definitions.json") # nginxのみ

  # Note: 他で必要なポリシーも含んでいるためロール追加
  # DockerコンテナがCloudWatch Logsにログを投げられるよう、ロール追加
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
  # TODO: task_role_arn は不要？
}

# # ECSサービスの定義
resource "aws_ecs_service" "startups_service" {
  name = "startups-service"
  cluster = aws_ecs_cluster.startups.arn
  task_definition = aws_ecs_task_definition.startups_app_nginx.arn
  desired_count = 2 # 維持するタスク数 # TODO: nginx, appが2つずつで合っているか確認
  deployment_minimum_healthy_percent = 100 # desired_countに対する最小タスク数（%）
  deployment_maximum_percent = 200 # desired_countに対する最大タスク数（%）
  launch_type = "FARGATE"
  platform_version = "1.3.0" # デフォルトのLATESTは非推奨
  health_check_grace_period_seconds = 60 # タスク起動時のヘルスチェック猶予期間、デフォルト0sのため設定

  network_configuration {
    assign_public_ip = false # プライベートネットワークで起動するため不要

    security_groups = [
      module.app_sg.security_group_id,
      module.db_sg.security_group_id
    ] # TODO: appも加えた場合の割り振り

    subnets = [ # タスク2台をマルチAZ化
      aws_subnet.private_1a.id,
      aws_subnet.private_1c.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.startups.arn
    container_name = "startups-nginx-11180755" # taskのnameに合わせる
    container_port = 80
  }

  lifecycle {
    # Fargateの場合、デプロイのたびにタスク定義が更新され、plan時に差分が出るため、リソースの初回作成時を除き変更を無視
    ignore_changes = [task_definition]
  }
}

# TODO: deployできたら追加（appも）
# module "nginx_sg" {
module "app_sg" {
  source = "./security_group"
  name = "startups-app-sg"
  vpc_id = aws_vpc.startups.id
  port = 80
  cidr_blocks = [aws_vpc.startups.cidr_block]
}

module "db_sg" {
  source = "./security_group"
  name = "startups-db-sg"
  vpc_id = aws_vpc.startups.id
  port = 3306
  cidr_blocks = [aws_vpc.startups.cidr_block]
}

# # module "app_sg" {
# #   source = "./security_group"
# #   name = "startups-app-sg"
# #   vpc_id = aws_vpc.startups.id
# #   port = 443 # TODO: これで十分か確認
# #   cidr_blocks = [aws_vpc.startups.cidr_block]

# #   # TODO: このappは、nginxからの通信を受け付けるなら違和感
# # }


# ECSはホストサーバーにSSHログインできず、コンテナのログを直接確認できない
# CloudWatch Logsと連携し、ログを記録
resource "aws_cloudwatch_log_group" "for_ecs" {
  name = "/ecs/startups"
  retention_in_days = 5 # ログの保持期間
}

# # ECSタスク実行IAMロール
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  # AWSが管理するポリシー、CloudWatch Logs, ECRの操作権限を持つ
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# # ECSタスク実行IAMロールのポリシードキュメント定義
data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy # 既存のポリシーを継承

  statement {
    effect = "Allow"
    actions = ["ssm:GetParamters", "kms:Decrypt"]
    resources = ["*"]
  }
}

# # IAMロールをmodule利用して作成
module "ecs_task_execution_role" {
  source = "./iam_role"
  name = "startups-ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com" # このIAMロールをECSで使用することを宣言
  policy = data.aws_iam_policy_document.ecs_task_execution.json
}


# # TODO: ECSでバッチ処理（10章）


# output aws_ecs_service_name {
#   value = aws_ecs_service.startups.name
# }

