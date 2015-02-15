class AddIndexesToPairs < ActiveRecord::Migration
  def change
    add_index :pairs, :member_1_id
    add_index :pairs, :member_2_id
  end
end
