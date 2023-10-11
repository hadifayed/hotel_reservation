class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.text :description
      t.integer :capacity, null: false
      t.decimal :price_per_night, null: false
      t.integer :lock_version, :null => false, :default => 0
      t.integer :reservation_count, :null => false, :default => 0

      t.timestamps
    end
  end
end
