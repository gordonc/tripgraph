require 'elasticsearch'

class Place < ActiveRecord::Base
  has_many :trip_places

  def from_elasticsearch(place)
    self.id = place['id']
    self.name = place['name']
    self.lat = place['location']['lat']
    self.lon = place['location']['lon']
  end

  def to_elasticsearch
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
