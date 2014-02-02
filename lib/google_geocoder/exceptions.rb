module GoogleGeocoder 
  class GeocodingError < StandardError
    include Nesty::NestedError
  end
end
