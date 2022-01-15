module ArticlesSearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks # 毎回更新がボトルネックになったら、バッチ処理・delayed_jobを考える

    index_name "es_articles_#{Rails.env}".downcase

    # indexの張り替えで、切り替えがうまくできていないため、未使用
    # index_name "es_articles_#{Time.current.strftime("%Y_%m_%d_%H_%M_%Z")}".downcase

    settings do
      mappings dynamic: 'false' do
        indexes :id, type: 'integer'
        # NOTE: Test to count used_articles but now count articles with media.
        # For aggregations https://qiita.com/yamashun/items/e1f2157e1b3cf3a716e3
        indexes :medium_id, type: 'integer'
        # indexes :medium_name, type: 'keyword'
        indexes :title, type: 'keyword'
        indexes :url, type: 'keyword'
        indexes :image, type: 'keyword'
        indexes :published, type: 'date'
        indexes :categories, type: 'text', analyzer: 'kuromoji'
        # For null search.(need to be keyword) https://github.com/elastic/elasticsearch-rails/issues/458
        indexes :deleted_at, type: 'keyword', null_value: 'NULL'
      end
    end

    def as_indexed_json(*)
      attributes
        .symbolize_keys
        .slice(:id, :medium_id, :title, :url, :image, :published, :categories, :deleted_at) # NOTE: mapping information will not be synchronized.
        # .merge(medium_name: medium_name)
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
        size: 100,
        query: {
          multi_match: { # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html
            # TODO: 重み付けをしたい
            fields: %i(title^3 categories medium_name),
            type: 'cross_fields', # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html#type-cross-fields
            query: query,
            operator: 'or',
          },
        }
      })
    end

    def es_search_all
      __elasticsearch__.search({
        size: 100,
        query: {
          match: {
            deleted_at: 'NULL' # 論理削除していないarticleを取得
          }
        },
        sort: [
          {
            id: "desc"
          }
        ]
      })
    end

    def count_articles_from_media
      __elasticsearch__.search({
        size: 100,
        query: {
          match: {
            deleted_at: 'NULL' # 論理削除していないarticleを取得
          }
        },
        aggs: {
          media: {
            terms: {
              field: "medium_id",
              size: 100
            }
          }
        }
      })
    end
  end
end

# Webコンテナでの操作
# NOTE: in rails c , and use reload! command

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
# curl -XGET 'localhost:9200/<index_name>/_mapping?pretty'

# 件数確認
# curl -sS -XGET 'localhost:9200/<index_name>/_doc/_count?pretty'

# ドキュメント取得（id=40）
# curl -XGET 'localhost:9200/<index_name>/_doc/40?pretty'

# search例
# curl -H "Content-Type: application/json" -XGET "localhost:9200/<index_name>/_search" -d'
# {
#   "query": {
#     "term": {
#       "title": "google"
#     }
#   }
# }'

# curl -H "Content-Type: application/json" -XGET "localhost:9200/<index_name>/_search" -d'
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