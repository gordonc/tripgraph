json.array!(@places) do |place|
  json.partial! place
end
