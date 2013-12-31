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

    name = doc.css("meta").select{|meta| meta['property'] == "og\:title"}[0]['content']

    places = doc.css("div#trip-itinerary div#itinerary-brief div.content h5").collect{|h5| strip_place_line(h5.content)}

    regions = doc.css("div#trip-itinerary div.summary div.content ul li").collect{|li| li.content}

    GAdventuresTripBuilder.perform_async({:name => name, :places => places, :regions => regions})

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
