class AddReminderCountToMembers < ActiveRecord::Migration
  def up
    add_column :members, :message_flags, :integer, null: false, default: 0
  end

  def down
    remove_column :members, :message_flags
  end


end
