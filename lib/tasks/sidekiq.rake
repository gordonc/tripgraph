namespace :sidekiq do

  namespace :stats do
    stats = Sidekiq::Stats.new

    desc "Display real-time sidekiq stats information"
    task :puts => :environment do
      puts "processed: #{stats.processed}"
      puts "failed: #{stats.failed}"
      puts "queues: #{stats.queues}"
      puts "enqueued: #{stats.enqueued}"
    end

    desc "Reset real-time sidekiq stats counters"
    task :reset => :environment do
      stats.reset
    end
  end

  namespace :queue do
    desc "Delete all jobs in sidekiq queue by removing queue"
    task :clear, [:queue] => :environment do |t, args|
      args.with_defaults(:queue => "default")
      queue = Sidekiq::Queue.new(args.queue)
      queue.clear
    end
  end

end
