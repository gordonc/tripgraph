class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.string :url
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
