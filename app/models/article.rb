class Article < ApplicationRecord
  # 論理削除
  acts_as_paranoid
  # Elasticsearch
  include ArticlesSearchable

  belongs_to :medium

  validates :title,
    presence: true,
    uniqueness: true
  validates :url,
    presence: true,
    uniqueness: true
  # tile, url 以外のカラムのバリデーションは一旦スキップ（記事によってタグ名が変更する可能性があると思われるため）
end
