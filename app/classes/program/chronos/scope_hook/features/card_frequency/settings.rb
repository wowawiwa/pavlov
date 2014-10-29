module Program::Chronos::ScopeHook::Features::CardFrequency::Settings
  SUCCESS_MIN_TSPAN_MIN = 5.minutes
  SUCCESS_MIN_TSPAN_DEFAULT = 1.hour

  def self.included( base)
    base.class_eval do
      duration_attrs chronos_success_min_tspan: { virtual_attr_name: :chronos_success_min_ts, max_scale: :days}
      
      validates_numericality_of :chronos_success_min_tspan, only_integer: true, greater_than_or_equal_to: SUCCESS_MIN_TSPAN_MIN
      after_initialize :set_chronos_success_min_tspan_default
      private
      def set_chronos_success_min_tspan_default
        self.chronos_success_min_tspan ||= SUCCESS_MIN_TSPAN_DEFAULT if new_record?
      end
    end
  end
end
