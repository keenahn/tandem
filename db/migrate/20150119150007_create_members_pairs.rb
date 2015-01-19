class CreateMembersPairs < ActiveRecord::Migration
  def change
    create_table :members_pairs do |t|
      t.belongs_to :member, index: true
      t.belongs_to :pair, index: true
    end
  end
end
