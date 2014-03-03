require 'elasticsearch'

class Place < ActiveRecord::Base
  has_many :trip_places

  @@es = Elasticsearch::Client.new trace: Tripgraph::Application::config.elasticsearch[:trace]

  unless @@es.indices.exists index: 'tripgraph'
    @@es.indices.create index: 'tripgraph'
  end

  @@es.indices.put_mapping(
    index: 'tripgraph',
    type: 'places',
    body: {
      places: {
        properties: {
          location: {
            type: 'geo_point'
          }
        }
      }
    }
  )

  def self.search(query, filter = nil)
    body = { query: query }
    unless filter.nil?
      body[:filter] = filter
    end

    results = @@es.search(
      index: 'tripgraph',
      type: 'places',
      body: body
    )

    places = []
    if results.has_key?('hits')
      hits = results['hits']
      if hits.has_key?('hits')
        hits = hits['hits']
        hits.each do |hit|
          if hit.has_key?('_source')
            _source = hit['_source']
            if _source.has_key?('places')
              place = Place.new
              place.from_elasticsearch(_source['places'])
              places << place
            end
          end
        end
      end
    end   

    return places
  end

  def index
    place = self.to_elasticsearch
    place['trips'] = []
    self.trip_places.each do |trip_place|
      trip = trip_place.trip.to_elasticsearch
      trip['ordinal'] = trip_place.ordinal
      place['trips'] << trip
    end

    @@es.index(
      index: 'tripgraph',
      type: 'places',
      id: self.id,
      body: {
        places: place
      }
    )
  end

  def from_elasticsearch(trip)
    self.id = trip['id']
    self.name = trip['name']
    self.lat = trip['location']['lat']
    self.lon = trip['location']['lon']
  end

  def to_elasticsearch
    {
      id: self.id,
      name: self.name,
      location: {
        lat: self.lat,
        lon: self.lon
      }
    }
  end
end
