class ChangePricePerNightInRoom < ActiveRecord::Migration[7.0]
  def change
    change_column :rooms, :price_per_night, :decimal, precision: 10, scale: 2
  end
end
