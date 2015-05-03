class CreateReminders < ActiveRecord::Migration
  def up
    create_table :reminders do |t|
      t.integer :pair_id
      t.integer :member_id
      t.integer :status, :integer, default: 0
      t.datetime :next_utc_time
      t.timestamps null: false
    end

    add_index :reminders, [:status, :next_utc_time]
    add_index :reminders, [:pair_id]
    add_index :reminders, [:member_id]

  end

  def down
    drop_table :reminders
  end
end
