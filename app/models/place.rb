require 'elasticsearch'

class Place < ActiveRecord::Base
  has_many :trip_places

  after_create :index

  @@es = Elasticsearch::Client.new

  @@es.indices.create index: 'place'
  @@es.indices.put_mapping index: 'place',
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

  def index
    @@es.index index: 'place',
               type: 'places',
               id: self.id,
               body: {
                 places: {
                   name: self.name,
                   location: {
                     lat: self.lat,
                     lon: self.lon
                   }
                 }
               }
  end
end
