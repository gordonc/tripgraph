class GAdventuresTripBuilder
  include Sidekiq::Worker
  def perform(parse_result)

    require 'geocoder'

    name = parse_result['name']
    places = parse_result['places']
    regions = parse_result['regions']

    trip = Trip.new({:name => name})
    trip.save

    if regions.length > 0
      country = regions[0]
      cc_tld = Geocoder.get_cc_tld(country)
      
      prev_place = nil
      places.each do |place|
        position = Geocoder.get_position(place, cc_tld)
        place = Place.new({:name => place, :lat => position['lat'], :lon => position['lon']})
        place.save

        unless prev_place.nil?
          trip_segment = TripSegment.new({:trip => trip, :from_place => prev_place, :to_place => place})
          trip_segment.save
        end

        prev_place = place
      end
    else
      raise "empty regions parse result for trip #{name}"
    end

  end
end
