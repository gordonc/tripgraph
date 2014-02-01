require 'elasticsearch'

namespace :elasticsearch do
  es = Elasticsearch::Client.new

  task reset: :environment do
    es.indices.delete index: '_all'
  end

end
