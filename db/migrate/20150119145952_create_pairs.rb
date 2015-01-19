class CreatePairs < ActiveRecord::Migration
  def change
    create_table :pairs do |t|
      t.references :group, index: true
      t.integer :user_id_1
      t.integer :user_id_2

      t.timestamps
    end
  end
end
