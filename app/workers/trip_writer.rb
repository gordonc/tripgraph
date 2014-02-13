class TripWriter
  include Sidekiq::Worker
  def perform(trip)

    places = trip['places']
    trip = Trip.find_or_create_by({:name => trip['name'], :url => trip['url']})

    places.each_with_index do |place, i|
      unless place.nil?
        place = Place.find_or_create_by({:name => place['name'], :lat => place['lat'], :lon => place['lon']})
        trip_place = TripPlace.find_or_create_by({:trip => trip, :place => place, :ordinal => i})
      end
    end

  end
end
