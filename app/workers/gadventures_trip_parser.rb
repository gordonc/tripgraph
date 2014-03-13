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
      trip_name = doc.css("div#content-head>div>h1>span")[0].content
    rescue => e
      raise Exceptions::TripParseError.new("error parsing doc for trip name", e)
    end
    begin 
      trip_description = doc.css("div#trip-description>p")[0].content
    rescue => e
      raise Exceptions::TripParseError.new("error parsing doc for trip description", e)
    end
    begin
      country_names = doc.css("div#trip-itinerary>div.summary>div.content>ul>li").collect{|li| li.content}
    rescue => e
      raise Exceptions::TripParseError.new("error parsing doc for country names", e)
    end

    itinerary = []
    begin
      nodes = doc.css("div#trip-itinerary>div#itinerary-brief>div.content").children
      i = 0
      while i < nodes.length()
        if nodes[i].name.eql?('h5')
          place_names = get_place_names_from_itinerary_line(nodes[i].content)
        else
        end
        i += 1
        if nodes[i].name.eql?('p')
          itinerary_item_description = nodes[i].content
        else
        end
        i += 1

        place_names.each do |place_name|
          itinerary << {'description' => itinerary_item_description, 'place' => {'name' => place_name}}
        end
      end
    rescue => e
      raise Exceptions::TripParseError.new("error parsing doc for itinerary lines", e)
    end

    TripBuilder.perform_async({'url' => uri.to_s, 'name' => trip_name, 'description' => trip_description, 'regions' => country_names, 'itinerary' => itinerary})

  end

  def get_place_names_from_itinerary_line(line)
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
