class GAdventuresTripBuilder
  include Sidekiq::Worker
  def perform(parse_result)

    require 'geocoder'

    name = parse_result['name']
    places = parse_result['places']
    regions = parse_result['regions']

    if regions.length > 0
      country = regions[0]
      cc_tld = Geocoder.get_cc_tld(country)
      
      places.each do |place|
        puts Geocoder.get_position(place, cc_tld)
      end
    else
      raise "empty regions parse result for trip #{name}"
    end

  end
end
