require 'redis'

namespace :redis do
  desc "Removes data from all redis databases"
  task reset: :environment do
    redis = Redis.new Tripgraph::Application.config.redis
    redis.flushall
  end

end
