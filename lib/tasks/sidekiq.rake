namespace :sidekiq do

  namespace :stats do
    stats = Sidekiq::Stats.new
    task :puts => :environment do
      puts "processed: #{stats.processed}"
      puts "failed: #{stats.failed}"
      puts "queues: #{stats.queues}"
      puts "enqueued: #{stats.enqueued}"
    end

    task :reset => :environment do
      stats.reset
    end
  end

  namespace :queue do
    task :clear, [:queue] => :environment do |t, args|
      args.with_defaults(:queue => "default")
      queue = Sidekiq::Queue.new(args.queue)
      queue.clear
    end
  end

end
