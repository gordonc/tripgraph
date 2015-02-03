require 'redis'

namespace :redis do
  desc "Removes data from all redis databases"
  task reset: :environment do
    redis = Redis.new Tripgraph::Application.config.redis
    redis.flushall
  end

  desc "Deletes keys by pattern"
  task :delete, [:pattern] => :environment do |t, args|
    redis = Redis.new Tripgraph::Application.config.redis
    keys = redis.keys(pattern=args.pattern)
    if not keys.empty?
      redis.del(keys)
    end
  end
end
