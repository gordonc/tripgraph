require 'google_geocoder'
require 'exceptions'

class TripBuilder
  include Sidekiq::Worker
  sidekiq_options :queue => :trip_builder

  @@geocoder = GoogleGeocoder::GoogleGeocoder.new

  def perform(trip)

    country_names = trip['regions']
    cc_tlds = get_cc_tlds(country_names)

    if cc_tlds.empty?
      raise Exceptions::TripParseError.new("error getting ccTLD for countries #{countries}")
    end

    itinerary = trip['itinerary']
    itinerary.each do |itinerary_item|
      begin
        place = itinerary_item['place']
        position = @@geocoder.get_position(place['name'], cc_tlds[0])
        if cc_tlds.include?(position.cc_tld)
          place['lat'] = position.lat
          place['lon'] = position.lon
        end
      rescue => e
        logger.warn("error geocoding place name #{place['name']}, region #{cc_tlds[0]}, #{e.message}")
      end
    end

    TripWriter.perform_async({'url' => trip['url'], 'name' => trip['name'], 'description' => trip['description'], 'itinerary' => itinerary})

  end

  def get_cc_tlds(countries)
    cc_tlds = []

    countries.each do |country|
      begin
        cc_tlds << @@geocoder.get_cc_tld(country)
      rescue => e
        logger.warn("error getting ccTLD for country #{country}, #{e.message}")
      end
    end

    return cc_tlds
  end
end
