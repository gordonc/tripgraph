class TripWriter
  include Sidekiq::Worker
  def perform(parse_result)

    name = parse_result['name']
    places = parse_result['places']

    trip = Trip.new({:name => name})
    trip.save

    prev_place = nil
    places.each do |place|
      place = Place.new({:name => place['name'], :lat => place['lat'], :lon => place['lon']})
      place.save

      unless prev_place.nil?
        trip_segment = TripSegment.new({:trip => trip, :from_place => prev_place, :to_place => place})
        trip_segment.save
      end

      prev_place = place
    end

  end
end
