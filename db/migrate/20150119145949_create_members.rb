class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :name
      t.string :phone_number
      t.boolean :active

      t.timestamps
    end
  end
end
