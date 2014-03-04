require 'google_geocoder'
require 'exceptions'

class TripBuilder
  include Sidekiq::Worker
  sidekiq_options :queue => :trip_builder

  @@geocoder = GoogleGeocoder::GoogleGeocoder.new

  def perform(trip)

    country_names = trip['regions']
    cc_tld = get_cc_tld(country_names)

    itinerary = trip['itinerary']
    itinerary.each do |itinerary_item|
      begin
        place = itinerary_item['place']
        position = @@geocoder.get_position(place['name'], cc_tld)
        place['lat'] = position.lat
        place['lon'] = position.lon
      rescue => e
        logger.warn("error geocoding place name #{place['name']}, region #{cc_tld}, #{e.message}")
      end
    end

    TripWriter.perform_async({'url' => trip['url'], 'name' => trip['name'], 'description' => trip['description'], 'itinerary' => itinerary})

  end

  def get_cc_tld(countries)
    countries.each do |country|
      begin
        return @@geocoder.get_cc_tld(country)
      rescue => e
        logger.warn("error getting ccTLD for country #{country}, #{e.message}")
      end
    end
    raise Exceptions::TripParseError.new("error getting ccTLD for countries #{countries}")
  end
end
