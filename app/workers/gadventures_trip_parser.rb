require 'nokogiri'
require 'open-uri'
require 'exceptions'

class GadventuresTripParser
  include Sidekiq::Worker
  sidekiq_options :queue => :trip_parser

  def perform(url)

    uri = URI.parse(url)

    r = Rails.cache.fetch(uri.to_s, :expires_in => 7.days) do
      open(uri).read
    end

    doc = Nokogiri::HTML(r)

    begin 
      trip_name = doc.css("meta").select{|meta| meta['property'] == "og\:title"}[0]['content']
    rescue => e
      raise Exceptions::TripParseError.new("error parsing doc for trip name", e)
    end
    begin
      country_names = doc.css("div#trip-itinerary>div.summary>div.content>ul>li").collect{|li| li.content}
    rescue => e
      raise Exceptions::TripParseError.new("error parsing doc for country names", e)
    end
    begin
      itinerary_lines = doc.css("div#trip-itinerary>div#itinerary-brief>div.content>h5").collect{|h5| h5.content}
    rescue => e
      raise Exceptions::TripParseError.new("error parsing doc for itinerary lines", e)
    end

    place_names = itinerary_lines.collect{|line| get_places_from_itinerary_line(line)}.flatten

    TripBuilder.perform_async({'url' => uri.to_s, 'trip_name' => trip_name, 'regions' => country_names, 'place_names' => place_names})

  end

  def get_places_from_itinerary_line(line)
    begin
      match = /^\s*Days?\s+\d+(\-\d+)?\s+(?<places>(\w|\p{Word}|\s)*)\s*/.match(line)
      places = match[:places].split('/')
      places = places.collect{|place| place.strip}
      return places
    rescue => e
      raise Exceptions::TripParseError.new("error parsing itinerary line #{line} for place name", e)
    end
  end
end
