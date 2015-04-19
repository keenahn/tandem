class CreateCheckins < ActiveRecord::Migration
  def change
    create_table :checkins do |t|
      t.integer :member_id
      t.integer :pair_id
      t.date :local_date
      t.datetime :done_at

      t.timestamps null: false
    end
  end
end
