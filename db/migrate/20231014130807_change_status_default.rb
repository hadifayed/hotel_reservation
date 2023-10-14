class ChangeStatusDefault < ActiveRecord::Migration[7.0]
  def up
    change_column_default :room_reservations, :status, 0
  end

  def down
    change_column_default :room_reservations, :status, 1
  end
end
