config = {
  transport_options: {
    request: { timeout: 30 }
  }
}

config.merge!(YAML.load_file('config/elasticsearch.yml')[Rails.env].symbolize_keys) if File.exist?('config/elasticsearch.yml')
Elasticsearch::Model.client = Elasticsearch::Client.new(config)