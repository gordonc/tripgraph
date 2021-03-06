require 'elasticsearch'

namespace :elasticsearch do
  es = Elasticsearch::Client.new Tripgraph::Application.config.elasticsearch

  desc "Delete all elasticsearch indices"
  task reset: :environment do
    es.indices.delete index: '_all'
  end

end
