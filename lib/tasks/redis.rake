require 'redis'

namespace :redis do
  redis = Redis.new

  desc "Removes data from all redis databases"
  task reset: :environment do
    redis.flushall
  end

end
