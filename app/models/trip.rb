require 'elasticsearch'

class Trip < ActiveRecord::Base
  has_many :trip_places

  after_create :index

  @@es = Elasticsearch::Client.new trace: true

  unless @@es.indices.exists index: 'trip'
    @@es.indices.create index: 'trip'
  end

  def self.search(query)
    results = @@es.search(
      index: 'trip',
      type: 'trips',
      body: { query: query }
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
      index: 'trip',
      type: 'trips',
      id: self.id,
      body: {
        trips: self.to_elasticsearch
      }
    )
  end

  def from_elasticsearch(trip)
    self.id = trip['id']
    self.name = trip['name']
    self.url = trip['url']
  end

  def to_elasticsearch()
    {
      id: self.id,
      name: self.name,
      url: self.url
    }
  end
end
