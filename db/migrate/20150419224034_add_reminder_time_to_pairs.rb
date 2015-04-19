class AddReminderTimeToPairs < ActiveRecord::Migration
  def up
    add_column :pairs, :time_zone, :string
    add_column :pairs, :reminder_time_mon, :time
    add_column :pairs, :reminder_time_tue, :time
    add_column :pairs, :reminder_time_wed, :time
    add_column :pairs, :reminder_time_thu, :time
    add_column :pairs, :reminder_time_fri, :time
    add_column :pairs, :reminder_time_sat, :time
    add_column :pairs, :reminder_time_sun, :time

    # This has to be raw sql for now, because AR doesn't provide a good way
    # to do update_all with joins
    sql = "
     UPDATE pairs
       SET time_zone = groups.time_zone
       FROM groups
        WHERE
          pairs.group_id = groups.id
    "

    update_sql(sql)


  end

  def down
    remove_column :pairs, :time_zone
    remove_column :pairs, :reminder_time_mon
    remove_column :pairs, :reminder_time_tue
    remove_column :pairs, :reminder_time_wed
    remove_column :pairs, :reminder_time_thu
    remove_column :pairs, :reminder_time_fri
    remove_column :pairs, :reminder_time_sat
    remove_column :pairs, :reminder_time_sun
  end

end
