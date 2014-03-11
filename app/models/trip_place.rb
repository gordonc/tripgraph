class TripPlace < ActiveRecord::Base
  belongs_to :trip
  belongs_to :place

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
