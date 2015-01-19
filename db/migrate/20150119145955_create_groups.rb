class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.references :user, index: true
      t.text :name
      t.text :description

      t.timestamps
    end
  end
end
