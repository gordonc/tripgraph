class TripWriter
  include Sidekiq::Worker
  sidekiq_options :queue => :trip_writer

  def perform(trip)

    trip_url = trip['url']
    trip_name = trip['name']
    trip_description = trip['description']
    itinerary = trip['itinerary']

    trip = Trip.find_or_initialize_by({:url => trip_url})
    trip.name = trip_name
    trip.description = trip_description
    trip.save

    itinerary.each_with_index do |itinerary_item, i|
      place = itinerary_item['place']

      place = Place.find_or_initialize_by({:name => place['name'], :lat => place['lat'], :lon => place['lon']})
      place.save

      trip_place = TripPlace.find_or_initialize_by({:trip => trip, :place => place, :ordinal => i + 1})
      trip_place.description = itinerary_item['description']
      trip_place.save

      trip_place.index
    end

  end
end
