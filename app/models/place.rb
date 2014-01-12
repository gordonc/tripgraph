class Place < ActiveRecord::Base
  has_many :trip_places
end
