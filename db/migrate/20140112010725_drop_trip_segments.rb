class DropTripSegments < ActiveRecord::Migration
  def change
    drop_table :trip_segments
  end
end
