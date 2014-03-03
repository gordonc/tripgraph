class TripPlace < ActiveRecord::Base
  belongs_to :trip
  belongs_to :place
end
