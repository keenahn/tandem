class AddIndexesToCheckins < ActiveRecord::Migration

  def up
    add_index :checkins, [:pair_id, :member_id, :local_date], unique: true
    add_index :checkins, [:member_id, :local_date]
  end

  def down
    remove_index :checkins, [:pair_id, :member_id, :local_date]
    remove_index :checkins, [:member_id, :local_date]
  end
end
