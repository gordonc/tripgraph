require 'redis'

namespace :redis do
  redis = Redis.new

  task reset: :environment do
    redis.flushall
  end

end
