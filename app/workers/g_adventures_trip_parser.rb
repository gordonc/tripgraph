class GAdventuresTripParser
  include Sidekiq::Worker
  def perform(url)

    require 'nokogiri'
    require 'open-uri'

    uri = URI.parse(url)

    r = Rails.cache.fetch(uri.to_s, :expires_in => 1.day) do
      open(uri).read
    end

    doc = Nokogiri::HTML(r)

    puts doc.css("meta").select{|meta| meta['property'] == "og\:title"}[0]['content']

    doc.css("div#trip-itinerary div.summary div.content ul li").each do |li|
      puts li.content
    end

    doc.css("div#trip-itinerary div#itinerary-brief div.content h5").each do |h5|
      puts h5.content
    end

  end
end
