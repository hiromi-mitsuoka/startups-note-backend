namespace :es_article do
  desc "create or re-cover article's index"
  task index: :environment do
    Article.create_index!
    p "DONE"
  end

  desc "import articles"
  task import: :environment do
    Article.__elasticsearch__.import
    p "DONE"
  end
end