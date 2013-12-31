class GAdventuresTripBuilder
  include Sidekiq::Worker
  def perform(parse_result)

    puts parse_result

  end
end
