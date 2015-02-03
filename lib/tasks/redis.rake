require 'redis'

namespace :redis do
  redis = Redis.new Tripgraph::Application.config.redis

  desc "Deletes all keys from current databases"
  task reset: :environment do
    redis.flushdb
  end

  desc "Deletes keys by pattern"
  task :delete, [:pattern] => :environment do |t, args|
    keys = redis.keys(pattern=args.pattern)
    if not keys.empty?
      redis.del(keys)
    end
  end
end
