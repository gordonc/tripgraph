class TripSegment < ActiveRecord::Base
  belongs_to :trip
  belongs_to :from_place, :class_name => 'Place'
  belongs_to :to_place, :class_name => 'Place'
end
