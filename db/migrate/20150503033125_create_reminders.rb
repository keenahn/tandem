class CreateReminders < ActiveRecord::Migration
  def up
    create_table :reminders do |t|
      t.integer :pair_id
      t.integer :member_id
      t.integer :status, default: 0
      t.datetime :next_reminder_time_utc
      t.timestamps null: false
    end

    add_index :reminders, [:status, :next_reminder_time_utc]
    add_index :reminders, [:pair_id]
    add_index :reminders, [:member_id]

  end

  def down
    drop_table :reminders
  end
end
