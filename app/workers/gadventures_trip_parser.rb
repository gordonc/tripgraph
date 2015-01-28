require 'nokogiri'
require 'open-uri'
require 'exceptions'

class GadventuresTripParser
  include Sidekiq::Worker
  sidekiq_options :queue => :trip_parser

  def perform(url)

    uri = URI.parse(url)

    r = Rails.cache.fetch(uri.to_s) do
      open(uri).read
    end

    doc = Nokogiri::HTML(r)

    begin
      nodes = doc.css("div[itemtype='http://schema.org/Product'] h1>span[itemprop='name']")
      if nodes.length > 0
        trip_name = nodes[0].content
      else
        raise Exceptions::TripParseError.new("empty trip name nodeset for doc #{url}")
      end
    rescue => e
      raise Exceptions::TripParseError.new("error parsing trip name for doc #{url}", e)
    end

    begin
      nodes = doc.css("div[itemtype='http://schema.org/Product'] p#trip-highlights")
      if nodes.length > 0
        trip_description = nodes[0].content
      else
        raise Exceptions::TripParseError.new("empty trip description nodeset for doc #{url}")
      end
    rescue => e
      raise Exceptions::TripParseError.new("error parsing trip description for doc #{url}", e)
    end

    begin
      nodes = doc.css("div[itemtype='http://schema.org/Product'] div#trip-itinerary h5~ul>li>a")
      if nodes.length > 0
        country_names = nodes.collect{|a| a.content}
      else
        raise Exceptions::TripParseError.new("empty country names nodeset for doc #{url}", e)
      end
    rescue => e
      raise Exceptions::TripParseError.new("error parsing country names for doc #{url}", e)
    end

    begin
      nodes = doc.css("div[itemtype='http://schema.org/Product'] div#trip-itinerary div#itinerary-brief>h5")
      if nodes.length > 0
        itinerary_place_names = nodes.collect{|h5| get_place_names_from_itinerary_line(h5.content)}
      else
        raise Exceptions::TripParseError.new("empty itinerary place names nodeset for doc #{url}", e)
      end
    rescue => e
      raise Exceptions::TripParseError.new("error parsing itinerary place names for doc #{url}", e)
    end

    begin
      nodes = doc.css("div[itemtype='http://schema.org/Product'] div#trip-itinerary div#itinerary-brief>p")
      if nodes.length > 0
        itinerary_item_descriptions = nodes.collect{|p| p.content}
      else
        raise Exceptions::TripParseError.new("empty itinerary descriptions nodeset for doc #{url}", e)
      end
    rescue => e
      raise Exceptions::TripParseError.new("error parsing itinerary description for doc #{url}", e)
    end

    if itinerary_place_names.length != itinerary_item_descriptions.length
      raise Exceptions::TripParseError.new("error parsing itinerary lines for doc #{url}")
    end

    itinerary = []
    itinerary_place_names.length.times do |i|
      place_names = itinerary_place_names[i]
      itinerary_item_description = itinerary_item_descriptions[i]

      place_names.each do |place_name|
        itinerary << {'description' => itinerary_item_description, 'place' => {'name' => place_name}}
      end
    end

    TripBuilder.perform_async({'url' => uri.to_s, 'name' => trip_name, 'description' => trip_description, 'regions' => country_names, 'itinerary' => itinerary})

  end

  def get_place_names_from_itinerary_line(line)
    begin
      match = /^\s*Days?\s+\d+(\-\d+)?\s+(?<places>(\w|\p{Word}|\p{Punct}|\s)*?)\s*(\(([BLD]|[0-9]|\s|\p{Punct})+\))?\s*$/.match(line)
      places = match[:places].split('/')
      places = places.collect{|place| place.strip}
      return places
    rescue => e
      raise Exceptions::TripParseError.new("error parsing itinerary line #{line} for place name", e)
    end
  end
end
