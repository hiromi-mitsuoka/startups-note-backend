namespace :es_article do
  desc "create or re-cover article's index"
  task index: :environment do
    Article.create_index!
    p "===== DONE Article.create_index! ====="
    Rails.logger.info("===== DONE Article.create_index! =====")
  end

  desc "import articles"
  task import: :environment do
    Article.__elasticsearch__.import
    p "===== DONE Article.__elasticsearch__.import ====="
    Rails.logger.info("===== DONE Article.__elasticsearch__.import =====")
  end
end