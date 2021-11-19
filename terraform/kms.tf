# # カスタマーマスターキー作成
# resource "aws_kms_key" "startups" {
#   description = "Customer Master Key for startups"
#   enable_key_rotation = true # 年に一度自動ローテーション、ローテション前に暗号化したデータの複号も引き続き可能
#   is_enabled = true # カスタマーマスターキーの有効化
#   deletion_window_in_days = 30　# 削除待機期間、デフォルト30日

#   # 削除したカスタマーマスターキーで暗号化したデータは、いかなる手段でも複合できない
# }

# # カスタマーマスターキーのUUIDは人間にわかりづらいためエイリアス設定
# resource "aws_kms_alias" "startups" {
#   name = "alias/startups"
#   target_key_id = aws_kms_key.startups.key_id
# }