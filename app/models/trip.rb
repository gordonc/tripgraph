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
    trip = self.to_elasticsearch
    trip['places'] = []
    self.trip_places.each do |trip_place|
      place = trip_place.place.to_elasticsearch
      place['ordinal'] = trip_place.ordinal
      trip['places'] << place
    end

    @@es.index(
      index: 'tripgraph',
      type: 'trips',
      id: self.id,
      body: {
        trips: trip
      }
    )
  end

  def from_elasticsearch(trip)
    self.id = trip['id']
    self.name = trip['name']
    self.url = trip['url']
  end

  def to_elasticsearch
    {
      id: self.id,
      name: self.name,
      url: self.url
    }
  end
end
