class GAdventuresTripParser
  include Sidekiq::Worker
  def perform(url)

    require 'nokogiri'
    require 'open-uri'
    require 'geocoder'

    uri = URI.parse(url)

    r = Rails.cache.fetch(uri.to_s, :expires_in => 7.days) do
      open(uri).read
    end

    doc = Nokogiri::HTML(r)

    trip_name = doc.css("meta").select{|meta| meta['property'] == "og\:title"}[0]['content']
    place_names = doc.css("div#trip-itinerary div#itinerary-brief div.content h5").collect{|h5| strip_place_line(h5.content)}
    country_names = doc.css("div#trip-itinerary div.summary div.content ul li").collect{|li| li.content}
    places = []

    if country_names.length > 0
      country_name = country_names[0]
      cc_tld = Geocoder.get_cc_tld(country_name)
      
      place_names.each do |place_name|
        position = Geocoder.get_position(place_name, cc_tld)
        places << {:name => place_name, :lat => position['lat'], :lon => position['lon']}
      end
    else
      raise "empty regions parse result for trip #{name}"
    end

    TripWriter.perform_async({:name => trip_name, :places => places})

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
