class ConvertListFieldsUnits < ActiveRecord::Migration
  def up
    List.all.each do |l|
      l.update_attribute :timebase_in_min, l.timebase_in_min*60 if l.timebase_in_min
      if old_val = l.capacity_timespan_in_hours
        old_val = (old_val/24)*24 # new val should represent multiple of days
        old_val = 1 if old_val == 0 # 0 is not an acceptable value
        new_val = old_val*3600 # convert in seconds
        l.update_attribute :capacity_timespan_in_hours, new_val
      end
    end
    rename_column :lists, :timebase_in_min, :chronos_success_min_tspan
    rename_column :lists, :capacity_timespan_in_hours, :chronos_capacity_tspan
    rename_column :lists, :capacity_count, :chronos_capacity_volume
  end
  def down
    List.all.each do |l|
      l.update_attribute :chronos_success_min_tspan, l.chronos_success_min_tspan/60 if l.chronos_success_min_tspan
      l.update_attribute :capacity_timespan_in_hours, l.chronos_capacity_tspan/3600 if l.chronos_capacity_tspan
    end
    rename_column :lists, :chronos_success_min_tspan, :timebase_in_min
    rename_column :lists, :chronos_capacity_tspan, :capacity_timespan_in_hours
    rename_column :lists, :chronos_capacity_volume, :capacity_count
  end
end
