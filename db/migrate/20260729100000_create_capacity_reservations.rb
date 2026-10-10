class CreateCapacityReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :capacity_reservations do |t|
      t.references :order, null: false, foreign_key: { to_table: :orders }, index: { unique: true }
      t.integer :units, null: false
      t.string :status, null: false, default: "reserved"
      t.datetime :expires_at
      t.datetime :committed_at
      t.datetime :released_at
      t.datetime :expired_at

      t.timestamps
    end

    add_index :capacity_reservations, :status
    add_index :capacity_reservations, :expires_at
  end
end
