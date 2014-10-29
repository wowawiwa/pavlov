module Program::Chronos::ScopeHook::Report

  # Return array of timespans (in seconds) before the next evaluation.
  def chronos_report_scheduled( reference_date)
    coming_dates = self.metas.next_eval_after( reference_date).pluck(:next_evaluation_date)
    coming_dates.map{|eval_date| eval_date - reference_date}
  end
end
