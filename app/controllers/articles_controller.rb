class ArticlesController < ApplicationController
  def index
    @articles = Article.all.order(id: :desc)
  end

  # def destroy
    # 論理削除追加済み
    # https://bagelee.com/programming/ruby-on-rails/using_rails_paranoia/
  # end
end
