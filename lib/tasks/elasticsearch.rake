require 'elasticsearch'

namespace :elasticsearch do
  desc "Delete all elasticsearch indices"
  task reset: :environment do
    es = Elasticsearch::Client.new Tripgraph::Application.config.elasticsearch
    es.indices.delete index: '_all'
  end

end
