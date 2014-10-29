class AddTimebaseAndCapacityToLists < ActiveRecord::Migration
  def up
    add_column :lists, :timebase_in_min, :integer
    add_column :lists, :capacity_count, :integer
    add_column :lists, :capacity_timespan_in_hours, :integer
    List.all.each do |l|
      l.save
    end
  end
  def down
    remove_column :lists, :timebase_in_min
    remove_column :lists, :capacity_count
    remove_column :lists, :capacity_timespan
  end
end
