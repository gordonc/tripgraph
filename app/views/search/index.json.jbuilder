json.array!(@trip_places) do |trip_place|
  json.partial! trip_place 
end
