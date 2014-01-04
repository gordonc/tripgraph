class TripWriter
  include Sidekiq::Worker
  def perform(trip)

    url = trip['url']
    name = trip['name']
    places = trip['places']

    trip = Trip.find_or_create_by({:url => url, :name => name})

    prev_place = nil
    places.each do |place|
      place = Place.find_or_create_by({:name => place['name'], :lat => place['lat'], :lon => place['lon']})

      unless prev_place.nil?
        trip_segment = TripSegment.find_or_create_by({:trip => trip, :from_place => prev_place, :to_place => place})
      end

      prev_place = place
    end

  end
end
