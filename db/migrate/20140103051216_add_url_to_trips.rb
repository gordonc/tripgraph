class AddUrlToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :url, :string, {:null => false, :default => ''}
    change_column_default :trips, :url, nil
    add_index :trips, :url, {:unique => true}
  end
end
