class RenameUser1OnPair < ActiveRecord::Migration
  def self.up
    rename_column :pairs, :user_id_1, :member_1_id
    rename_column :pairs, :user_id_2, :member_2_id
  end

  def self.down
    rename_column :pairs, :member_1_id, :user_id_1
    rename_column :pairs, :member_2_id, :user_id_2
  end
end
