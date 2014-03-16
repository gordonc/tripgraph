class Trip < ActiveRecord::Base
  has_many :trip_places

  def from_elasticsearch(trip)
    self.id = trip['id']
    self.url = trip['url']
    self.name = trip['name']
    self.description = trip['description']
  end

  def to_elasticsearch
    {
      id: self.id,
      url: self.url,
      name: self.name,
      description: self.description
    }
  end
end
