class AddTandemNumberToPairs < ActiveRecord::Migration

  def up
    add_column :pairs, :tandem_number, :string
    add_index :pairs, [:tandem_number, :member_1_id]
    add_index :pairs, [:tandem_number, :member_2_id]

    Pair.update_all(tandem_number: ENV["TWILIO_DEFAULT_FROM_NUMBER"])
  end

  def down
    remove_column :pairs, :tandem_number
  end

end
