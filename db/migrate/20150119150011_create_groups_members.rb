class CreateGroupsMembers < ActiveRecord::Migration
  def change
    create_table :groups_members do |t|
      t.belongs_to :group, index: true
      t.belongs_to :member, index: true
    end
  end
end
