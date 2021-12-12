class CreateArticlesEsIndexAndImport < ActiveRecord::Migration[6.1]
  def up
    Rake::Task['es_article:index'].invoke # create or re-cover index
    Rake::Task['es_article:import'].invoke # import articles
  end

  def down
  end
end
