require 'nokogiri'
require 'open-uri'
require 'google_geocoder'
require 'exceptions'

class GadventuresTripParser
  include Sidekiq::Worker
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

    cc_tld = get_cc_tld(country_names)
    place_names = itinerary_lines.collect{|line| get_places_from_itinerary_line(line)}.flatten

    places = []
    place_names.each do |place_name|
      begin
        position = GoogleGeocoder.get_position(place_name, cc_tld)
        places << {:name => place_name, :lat => position.lat, :lon => position.lon}
      rescue => e
        raise Exceptions::TripParseError.new("error geocoding place name #{place_name}, region #{cc_tld}", e)
      end
    end

    TripWriter.perform_async({:url => uri.to_s, :name => trip_name, :places => places})

  end

  def get_places_from_itinerary_line(line)
    begin
      match = /^\s*Days?\s+\d+(\-\d+)?\s+(?<places>(\w|\p{Word}|\s)*)\s*/.match(line)
      places = match[:places].split('/')
      return places
    rescue => e
      raise Exceptions::TripParseError.new("error parsing itinerary line #{line} for place name", e)
    end
  end

  def get_cc_tld(countries)
    countries.each do |country|
      begin
        return GoogleGeocoder.get_cc_tld(country)
      rescue
      end
    end
    raise Exceptions::TripParseError.new("error getting ccTLD from countries #{countries}")
  end
end
