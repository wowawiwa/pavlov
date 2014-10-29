module Program::Chronos::ScopeHook::Features::ReviewDailyCapacity::Settings
  CAPACITY_TSPAN_MIN = 1.hour
  CAPACITY_VOLUME_DEFAULT = nil 
  CAPACITY_TSPAN_DEFAULT = nil

  def self.included( base)
    base.class_eval do
      duration_attrs chronos_capacity_tspan: {  virtual_attr_name: :chronos_capacity_ts, max_scale: :days}

      validates_numericality_of :chronos_capacity_tspan, allow_nil: true, only_integer: true, greater_than_or_equal_to: CAPACITY_TSPAN_MIN
      validates_numericality_of :chronos_capacity_volume, allow_nil: true, only_integer: true, greater_than_or_equal_to: 0
      before_save :chronos_capacity_consistency
      after_initialize :set_default_chronos_capacity
      
      private

      def chronos_capacity_consistency
        self.chronos_capacity_tspan = self.chronos_capacity_volume = nil if !!self.chronos_capacity_tspan != !!self.chronos_capacity_volume 
      end
      def set_default_chronos_capacity
        if new_record?
          self.chronos_capacity_volume ||= CAPACITY_VOLUME_DEFAULT
          self.chronos_capacity_tspan ||= CAPACITY_TSPAN_DEFAULT
        end
      end
    end
  end

  # Return true if a capacity is set, false otherwise.
  def capacity_set?
    return !!self.chronos_capacity_volume
  end

  # Return remaining capacity (positive or negative),
  # answering whether this scope should be further evaluated according to the capacity settings,
  # i.e. contains a card (the next_evaluation date of which is in the past)
  # which should be evaluated according the capacity settings.
  def remaining_capacity( reference_date)
    return nil if not capacity_set?
    [chronos_capacity_volume - charge( reference_date, chronos_capacity_tspan), 0].max
  end
end
