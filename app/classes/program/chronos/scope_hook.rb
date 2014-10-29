# TODO rename following with chronos_timebase, chronos_throughput (serialized)
# To be mixed in a scope of ChronosCards (CardMeta)
module Program::Chronos::ScopeHook
  def self.included( base)
    # Supposes including to 
    # * #card, #card.meta
    # * #checkables
    # * Card#Meta
    base.class_eval do
      has_many :meta_cards, through: :cards, source: :meta
      def metas
        meta_cards.merge( checkables)
      end
    end
    # Supposes:
    # * #chronos_success_min_tspan field
    base.include Features::CardFrequency::Settings
    # Supposes:
    # * #chronos_capacity_tspan
    # * #chronos_capacity_volume
    base.include Features::ReviewDailyCapacity::Settings
    base.include Features::ReviewDailyCapacity::Report
    # Supposes:
    # * Relationship card : Scope -> Card, meta : Card -> CardMeta (ChronosCard)
    base.include Report
  end

end
