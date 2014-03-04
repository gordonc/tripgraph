require 'elasticsearch'

class Trip < ActiveRecord::Base
  has_many :trip_places

  @@es = Elasticsearch::Client.new trace: Tripgraph::Application::config.elasticsearch[:trace]

  unless @@es.indices.exists index: 'tripgraph'
    @@es.indices.create index: 'tripgraph'
  end

  @@es.indices.put_mapping(
    index: 'tripgraph',
    type: 'trips',
    body: {
      trips: {
        properties: {
          places: {
            properties: {
              location: {
                type: 'geo_point'
              }
            }
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
      type: 'trips',
      body: body
    )

    trips = []
    if results.has_key?('hits')
      hits = results['hits']
      if hits.has_key?('hits')
        hits = hits['hits']
        hits.each do |hit|
          if hit.has_key?('_source')
            _source = hit['_source']
            if _source.has_key?('trips')
              trip = Trip.new
              trip.from_elasticsearch(_source['trips'])
              trips << trip
            end
          end
        end
      end
    end   

    return trips
  end

  def index
    @@es.index(
      index: 'tripgraph',
      type: 'trips',
      id: self.id,
      body: {
        trips: self.to_elasticsearch
      }
    )
  end

  def from_elasticsearch(trip)
    self.id = trip['id']
    self.url = trip['url']
    self.name = trip['name']
    self.description = trip['description']
  end

  def to_elasticsearch
    {
      id: self.id,
      url: self.url,
      name: self.name,
      description: self.description,
      places:
        self.trip_places.collect do |trip_place|
          {
            ordinal: trip_place.ordinal,
            id: trip_place.place.id,
            name: trip_place.place.name,
            location: {
              lat: trip_place.place.lat,
              lon: trip_place.place.lon
            },
            description: trip_place.description
          }
        end
    }
  end
end
