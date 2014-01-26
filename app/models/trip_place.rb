class TripPlace < ActiveRecord::Base
  belongs_to :trip
  belongs_to :place

  after_create :index

  @@es = Elasticsearch::Client.new trace: true

  unless @@es.indices.exists index: 'trip'
    @@es.indices.create index: 'trip'
  end

  @@es.indices.put_mapping(
    index: 'trip',
    type: 'places',
    body: {
      places: {
        _parent: {
          type: "trips"
        },
        properties: {
          location: {
            type: 'geo_point'
          }
        }
      }
    }
  )

  unless @@es.indices.exists index: 'place'
    @@es.indices.create index: 'place'
  end

  @@es.indices.put_mapping(
    index: 'place',
    type: 'trips',
    body: {
      trips: {
        _parent: {
          type: "places"
        }
      }
    }
  )

  def index 
    @@es.index(
      index: 'trip',
      type: 'places',
      parent: self.trip.id,
      id: self.place.id,
      body: {
        places: self.place.to_elasticsearch
      }
    )

    @@es.index(index: 'place',
      type: 'trips',
      parent: self.place.id,
      id: self.trip.id,
      body: {
        trips: self.trip.to_elasticsearch
      }
    )
  end
end
