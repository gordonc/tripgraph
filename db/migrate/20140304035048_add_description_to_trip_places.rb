class AddDescriptionToTripPlaces < ActiveRecord::Migration
  def change
    add_column :trip_places, :description, :text
  end
end
