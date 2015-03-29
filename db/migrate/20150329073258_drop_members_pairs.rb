class DropMembersPairs < ActiveRecord::Migration
  def up
    drop_table :members_pairs

    add_column :pairs, :active, :boolean, default: true, null: false
    add_index :pairs, :active
  end

  def down
    create_table :members_pairs do |t|
      t.belongs_to :member, index: true
      t.belongs_to :pair, index: true
    end
    remove_column :pairs, :active
  end


end
