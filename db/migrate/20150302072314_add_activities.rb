class AddActivities < ActiveRecord::Migration
  def change
    add_column :groups, :activity, :string
    add_column :pairs, :activity, :string

    add_index :groups, :activity
    add_index :pairs, :activity

  end
end
