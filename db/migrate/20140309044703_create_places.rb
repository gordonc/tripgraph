class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :name
      t.decimal :lat, precision: 8, scale: 6
      t.decimal :lon, precision: 9, scale: 6

      t.timestamps
    end
  end
end
