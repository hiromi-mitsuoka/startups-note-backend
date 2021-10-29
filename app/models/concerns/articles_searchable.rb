module ArticlesSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks # 毎回更新がボトルネックになったら、バッチ処理・delayed_jobを考える

    index_name "es_articles_#{Rails.env}"
    # index_name "es_articles_#{Time.current.strftime("%Y_%m_%d")}"

    settings do
      mappings dynamic: 'false' do
        indexes :id, type: 'integer'
        indexes :medium_name, type: 'keyword'
        indexes :title, type: 'keyword'
        indexes :url, type: 'keyword'
        indexes :image, type: 'keyword'
        indexes :published, type: 'date'
        indexes :categories, type: 'text', analyzer: 'kuromoji'
        # indexes :created_at, type: 'date'
        # indexes :updated_at, type: 'date'
        # indexes :deleted_at, type: 'date'
      end
    end

    def as_indexed_json(*)
      attributes
        .symbolize_keys
        .slice(:id, :title, :url, :image, :published, :categories)
        .merge(medium_name: medium_name)
    end
  end

  def medium_name
    medium.name
  end

  class_methods do
    def create_index!
      client = __elasticsearch__.client
      # 既に作成されている場合は、削除してから再度作成。
      client.indices.delete index: self.index_name rescue nil
      client.indices.create(
        index: self.index_name,
        body: {
          settings: self.settings.to_hash,
          mappings: self.mappings.to_hash,
        }
      )
    end

    def es_search(query)
      __elasticsearch__.search({
        query: {
          multi_match: { # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html
            # TODO: 重み付けをしたい
            fields: %i(title^3 categories medium_name),
            type: 'cross_fields', # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html#type-cross-fields
            query: query,
            operator: 'or',
          }
        }
      })
    end
  end
end

# Webコンテナでの操作

# Elasticsearchとの接続確認
# Article.__elasticsearch__.client.cluster.health

# indexの作成
# Article.create_index!

# データ投入
# Article.__elasticsearch__.import



# Elasticsearchコンテナでの操作

# index一覧
# curl -XGET 'localhost:9200/_cat/indices'

# mapping確認
# curl -XGET 'localhost:9200/es_articles_development/_mapping?pretty'

# 件数確認
# curl -sS -XGET 'localhost:9200/es_articles_development/_doc/_count?pretty'

# ドキュメント取得（id=50）
# curl -XGET 'localhost:9200/es_articles_development/_doc/50?pretty'

# search例
# curl -H "Content-Type: application/json" -XGET "localhost:9200/es_articles_development/_search" -d'
# {
#   "query": {
#     "term": {
#       "title": "google"
#     }
#   }
# }'

# curl -H "Content-Type: application/json" -XGET "localhost:9200/es_articles_development/_search" -d'
# {
#   "query": {
#     "multi_match": {
#       "fields": ["title", "categories"],
#       "type": "cross_fields",
#       "query": "facebook",
#       "operator": "or"
#     }
#   }
# }'