json.array!(@trips) do |trip|
  json.partial! trip 
end
