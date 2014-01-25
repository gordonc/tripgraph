require 'elasticsearch'

class Place < ActiveRecord::Base
  has_many :trip_places

  after_create :index

  @@es = Elasticsearch::Client.new

  unless @@es.indices.exists index: 'place'
    @@es.indices.create index: 'place'
  end

  @@es.indices.put_mapping(
    index: 'place',
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

  def self.search(query)
    results = @@es.search(
      index: 'place',
      type: 'places',
      body: { query: query }
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
    @@es.index(
      index: 'place',
      type: 'places',
      id: self.id,
      body: {
        places: self.to_elasticsearch
      }
    )
  end

  def from_elasticsearch(trip)
    self.id = trip['id']
    self.name = trip['name']
    self.lat = trip['location']['lat']
    self.lon = trip['location']['lon']
  end

  def to_elasticsearch()
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
