class CreateSms < ActiveRecord::Migration
  def up
    create_table :sms do |t|
      t.integer :from_id
      t.string :from_type
      t.integer :to_id
      t.string :to_type
      t.string :from_number
      t.string :to_number
      t.string :message
      t.timestamps
    end

    add_index :sms, :from_number
    add_index :sms, :to_number
    add_index :sms, [:from_id, :from_type]
    add_index :sms, [:to_id, :to_type]


  end

  def down
    drop_table :sms
  end
end
