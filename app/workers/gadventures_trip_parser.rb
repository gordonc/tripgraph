class GadventuresTripParser
  include Sidekiq::Worker
  def perform(url)

    require 'nokogiri'
    require 'open-uri'
    require 'google_geocoder'

    uri = URI.parse(url)

    r = Rails.cache.fetch(uri.to_s, :expires_in => 7.days) do
      open(uri).read
    end

    doc = Nokogiri::HTML(r)

    begin 
      trip_name = doc.css("meta").select{|meta| meta['property'] == "og\:title"}[0]['content']
    rescue => e
      raise GadventuresParseError.new("error parsing doc for trip_name", e)
    end
    begin
      place_names = doc.css("div#trip-itinerary>div#itinerary-brief>div.content>h5").collect{|h5| strip_place_line(h5.content)}
    rescue => e
      raise GadventuresParseError.new("error parsing doc for place_names", e)
    end
    begin
      country_names = doc.css("div#trip-itinerary>div.summary>div.content>ul>li").collect{|li| li.content}
    rescue => e
      raise GadventuresParseError.new("error parsing doc for country_names", e)
    end
    places = []

    cc_tld = get_cc_tld(country_names)
    place_names.each do |place_name|
      position = GoogleGeocoder.get_position(place_name, cc_tld)
      places << {:name => place_name, :lat => position['lat'], :lon => position['lon']}
    end

    TripWriter.perform_async({:url => uri.to_s, :name => trip_name, :places => places})

  end

  def strip_place_line(line)
      match = /^\s*Days?\s+\d+(\-\d+)?\s+(?<place>(\w|\p{Word}|\s)*)\s*/.match(line)
      place = match[:place]
      return place
  end

  def get_cc_tld(countries)
    countries.each do |country|
      begin
        return GoogleGeocoder.get_cc_tld(country)
      rescue
      end
    end
    raise "unable to get ccTLD from countries #{countries}"
  end
end
