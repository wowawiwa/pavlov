module Program::Chronos::ScopeHook::Features::ReviewDailyCapacity::Report

  # Returns a hash with ready and pending number of cards.
  def chronos_report_flow( reference_date)
    # TODO rename ready in pending and pending in sleeping or whatever
    _total_candidates = self.metas.next_eval_before( reference_date).count
    if capacity_set?
      _remaining_capacity = chronos_capacity_volume - charge( reference_date, chronos_capacity_tspan)
      ready = [0, [ _total_candidates, _remaining_capacity].min].max
      pending = _total_candidates - ready
      capacity = true
    else
      ready = _total_candidates
      pending = nil
      capacity = false
    end
    return {ready: ready, pending: pending, capacity: capacity, chronos_capacity_volume: chronos_capacity_volume, chronos_capacity_tspan: chronos_capacity_tspan}
  end

  private

  def charge( reference_date, time_span)
    # Number of cards evaluated with a successful result in the last time_span
    self.evaluations.created_between(reference_date - time_span, reference_date).where(result: true).pluck(:card_id).uniq.count
  end
end
