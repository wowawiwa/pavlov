module Program::Chronos::EvaluationHook
  extend self

  def report_result card, evaluation_result, is_correction=false
    capacity_tspan = card.list.capacity_set? ? card.list.chronos_capacity_tspan : 0
    rhythm_tspan = card.list.chronos_success_min_tspan

    card.meta.report_result(is_correction) do |before_state, new_state|
      evaluation_date = Time.zone.now
      new_state.merge! Program::Chronos::Algos::Legacy.run_iteration( before_state, evaluation_result, evaluation_date, rhythm_tspan, capacity_tspan)
      new_state.merge! Program::Chronos::Algos::ProvenMax.run_iteration( before_state, evaluation_result, evaluation_date, rhythm_tspan, capacity_tspan)
    end
  end
end
