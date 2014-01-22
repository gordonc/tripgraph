class TripPlace < ActiveRecord::Base
  belongs_to :trip
  belongs_to :place

  after_create :index

  @@es = Elasticsearch::Client.new

  @@es.indices.put_mapping index: 'trip',
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

  @@es.indices.put_mapping index: 'place',
                           type: 'trips',
                           body: {
                             trips: {
                               _parent: {
                                 type: "places"
                               }
                             }
                           }

  def index 
    @@es.index index: 'trip',
               type: 'places',
               parent: self.trip.id,
               id: self.place.id,
               body: {
                 places: {
                   name: self.place.name,
                   location: {
                     lat: self.place.lat,
                     lon: self.place.lon
                   }
                 }
               }

    @@es.index index: 'place',
               type: 'trips',
               parent: self.place.id,
               id: self.trip.id,
               body: {
                 trips: {
                   name: self.trip.name,
                   name: self.trip.url
                 }
               }
  end
end
