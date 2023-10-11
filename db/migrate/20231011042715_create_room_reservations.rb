class CreateRoomReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :room_reservations do |t|
      t.references :room, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.datetime :check_in, null: false
      t.datetime :check_out, null: false
      t.integer :status, null: false, default: 1

      t.timestamps
    end
  end
end
