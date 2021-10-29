config = {
  host: "startups_elasticsearch:9200/", # 後ほどENV['ELASTICSEARCH_HOST'] || "startups_elasticsearch:9200/" などに置き換える
  # https://qiita.com/yamashun/items/6ecaa6f161b4cf283db3
}

Elasticsearch::Model.client = Elasticsearch::Client.new(config)