class AddTempRescheduleTimeToReminders < ActiveRecord::Migration
  def up
    add_column :reminders, :temp_reschedule_time_utc, :datetime
    add_index :reminders, :temp_reschedule_time_utc
  end

  def down
    remove_column :reminders, :temp_reschedule_time_utc
  end
end
