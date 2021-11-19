# # SSMパラメータストアの値は、ECSのDockerコンテナ内で環境変数として参照できる（ポリシー必要）

# resource "aws_ssm_parameter" "db_username" {
#   name = "/db/username"
#   value = "startups"
#   type = "String"
#   description = "DB username"
# }

# # apply時に、AWS CLIから更新
# resource "aws_ssm_parameter" "db_password" {
#   name = "/db/password"
#   value = "dummypassword"
#   type = "SecureString"
#   description = "DB password"

#   lifecycle {
#     ignore_changes = [value]
#   }
# }