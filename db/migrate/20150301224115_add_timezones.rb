class AddTimezones < ActiveRecord::Migration
  def self.up
    add_column :users, :time_zone, :string, default: User::DEFAULT_TIMEZONE
    add_column :groups, :time_zone, :string, default: User::DEFAULT_TIMEZONE
    add_column :members, :time_zone, :string, default: User::DEFAULT_TIMEZONE
  end

  def self.down
    remove_column :users, :time_zone
    remove_column :groups, :time_zone
    remove_column :members, :time_zone
  end

end
