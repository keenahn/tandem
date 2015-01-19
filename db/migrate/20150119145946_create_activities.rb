class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :language
      t.string :present_indicative
      t.string :present_particple
      t.string :past_participle
      t.string :noun
      t.string :short_noun

      t.timestamps
    end
  end
end
