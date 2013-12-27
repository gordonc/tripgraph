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
      puts strip_place_line(h5.content)
    end

  end

  def strip_place_line(line)
      place = line
      # strip days prefix
      place = place.sub(%r{^\s*Days?\s+\d+\s+}, '')
      # strip meals suffix
      place = place.sub(%r{\s+\((\d+[BLD]\,?)+\)\s*}, '')
      return place
  end
end
