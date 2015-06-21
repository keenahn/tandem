class AddGenderToMembers < ActiveRecord::Migration
  def change
    add_column :members, :gender, :integer, default: 0
  end
end
