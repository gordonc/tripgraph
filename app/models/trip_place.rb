class TripPlace < ActiveRecord::Base
  belongs_to :trip
  belongs_to :place

  @@es = Elasticsearch::Client.new trace: Tripgraph::Application::config.elasticsearch[:trace]

  unless @@es.indices.exists index: 'tripgraph'
    @@es.indices.create index: 'tripgraph'
  end

  @@es.indices.put_mapping(
    index: 'tripgraph',
    type: 'trip_places',
    body: {
      trip_places: {
        properties: {
          place: {
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
      type: 'trip_places',
      body: body
    )

    trip_places = []
    if results.has_key?('hits')
      hits = results['hits']
      if hits.has_key?('hits')
        hits = hits['hits']
        hits.each do |hit|
          if hit.has_key?('_source')
            _source = hit['_source']
            if _source.has_key?('trip_places')
              trip_place = TripPlace.new
              trip_place.from_elasticsearch(_source['trip_places'])
              trip_place.trip = Trip.new
              trip_place.trip.from_elasticsearch(_source['trip_places']['trip'])
              trip_place.place = Place.new
              trip_place.place.from_elasticsearch(_source['trip_places']['place'])
              trip_places << trip_place
            end
          end
        end
      end
    end

    return trip_places
  end

  def index
    trip_place = self.to_elasticsearch
    trip_place['trip'] = self.trip.to_elasticsearch
    trip_place['place'] = self.place.to_elasticsearch

    @@es.index(
      index: 'tripgraph',
      type: 'trip_places',
      id: self.id,
      body: {
        trip_places: trip_place
      }
    )
  end

  def from_elasticsearch(trip_place)
    self.id = trip_place['id']
    self.ordinal = trip_place['ordinal']
    self.description = trip_place['description']
  end

  def to_elasticsearch
    {
      id: self.id,
      ordinal: self.ordinal,
      description: self.description
    }
  end
end
