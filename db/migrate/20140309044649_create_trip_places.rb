class CreateTripPlaces < ActiveRecord::Migration
  def change
    create_table :trip_places do |t|
      t.integer :ordinal
      t.references :trip, index: true
      t.references :place, index: true
      t.text :description

      t.timestamps
    end
  end
end
