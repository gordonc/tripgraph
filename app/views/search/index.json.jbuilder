require 'set'

trip_ids = Set.new
trips = []
@trip_places.each do |trip_place|
  unless trip_ids.include?(trip_place.trip.id)
    trips << trip_place.trip
    trip_ids << trip_place.trip.id
  end
end

json.trips do
  json.array!(trips) do |trip|
      json.(trip, :id, :name)
  end
end

place_ids = Set.new
places = []
@trip_places.each do |trip_place|
  unless place_ids.include?(trip_place.place.id)
    places << trip_place.place
    place_ids << trip_place.place.id
  end
end

json.places do
  json.array!(places) do |place|
      json.(place, :id, :name, :lat, :lon)
  end
end

json.trip_places do
  json.array!(@trip_places) do |trip_place|
    json.(trip_place, :id, :ordinal)
    json.trip_id trip_place.trip.id
    json.place_id trip_place.place.id
  end
end
