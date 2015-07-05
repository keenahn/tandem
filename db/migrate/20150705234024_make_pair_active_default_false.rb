class MakePairActiveDefaultFalse < ActiveRecord::Migration
  def change
    change_column  :pairs, :active, :boolean, default: false, null: false
  end
end
