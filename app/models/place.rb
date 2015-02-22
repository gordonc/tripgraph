class Place < ActiveRecord::Base
  has_many :trip_places

  def from_elasticsearch(place)
    self.id = place['id']
    self.name = place['name']
    if not place['location'].nil?
      self.lat = place['location']['lat']
      self.lon = place['location']['lon']
    end
  end

  def to_elasticsearch
    {
      id: self.id,
      name: self.name,
      location: self.location_to_elasticsearch
    }
  end

  def location_to_elasticsearch
    if self.lat.nil? or self.lon.nil?
      nil
    else
      {
        lat: self.lat,
        lon: self.lon
      }
    end
  end
end
