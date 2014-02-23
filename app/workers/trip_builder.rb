require 'google_geocoder'
require 'exceptions'

class TripBuilder
  include Sidekiq::Worker
  sidekiq_options :queue => :trip_builder

  @@geocoder = GoogleGeocoder::GoogleGeocoder.new

  def perform(trip)

    url = trip['url']
    trip_name = trip['trip_name']
    country_names = trip['regions']
    place_names = trip['place_names']

    cc_tld = get_cc_tld(country_names)

    places = []
    place_names.each do |place_name|
      begin
        position = @@geocoder.get_position(place_name, cc_tld)
        places << {:name => place_name, :lat => position.lat, :lon => position.lon}
      rescue => e
        logger.warn("error geocoding place name #{place_name}, region #{cc_tld}, #{e.message}")
        places << nil
      end
    end

    TripWriter.perform_async({'url' => url, 'name' => trip_name, 'places' => places})

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
