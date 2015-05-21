class AddLastReminderTimeUtcToReminders < ActiveRecord::Migration
  def up
    add_column :reminders, :last_reminder_time_utc, :datetime
    add_column :reminders, :last_no_reply_sent_time_utc, :datetime
    add_index :reminders, :last_reminder_time_utc
  end

  def down
    remove_column :reminders, :last_reminder_time_utc, :datetime
  end

end
