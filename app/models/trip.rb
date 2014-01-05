require 'elasticsearch'

class Trip < ActiveRecord::Base
  has_many :trip_places

  after_create :index

  @@es = Elasticsearch::Client.new

  @@es.indices.create index: 'trip'

  def index
    @@es.index index: 'trip',
               type: 'trips',
               id: self.id,
               body: {
                 trips: {
                   name: self.name,
                   url: self.url
                 }
               }
  end
end
