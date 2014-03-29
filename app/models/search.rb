require 'elasticsearch'

class Search
  @@es = Elasticsearch::Client.new Tripgraph::Application.config.elasticsearch

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

  def self.search(query, top_left, bottom_right)
    body = {
      size: 25,
      query: {
        multi_match: {
          query: query,
          fields: ['description', 'trip.name', 'trip.description', 'place.name']
        }
      }
    }

    if not top_left.nil? and not bottom_right.nil?
      body[:filter] = {
        geo_bounding_box: {
          'place.location' => {
            top_left: top_left,
            bottom_right: bottom_right
          }
        }
      }
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

  def self.index(trip_place)
    id = trip_place.id
    trip = trip_place.trip
    place = trip_place.place
    
    trip_place = trip_place.to_elasticsearch
    trip_place['trip'] = trip.to_elasticsearch
    trip_place['place'] = place.to_elasticsearch

    @@es.index(
      index: 'tripgraph',
      type: 'trip_places',
      id: id,
      body: {
        trip_places: trip_place
      }
    )
  end
end
