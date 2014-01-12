class CreateTripPlaces < ActiveRecord::Migration
  def change
    create_table :trip_places do |t|
      t.references :trip, index: true
      t.references :place, index: true
      t.integer :ordinal

      t.timestamps
    end
  end
end
