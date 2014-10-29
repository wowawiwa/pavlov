# The current successive timespan (time between now and the last fail) is seen as the sum of the terms of a geometric sequence.
# The time to wait before the next step is the n+1th term of the sequence, where n is the term that corresponds to the current successive timespan.
module Program::Chronos::Algos::GeoSequence
  extend self

  def time_before_next_evaluation(hash)
    virtual_current_successful_timespan(hash) * 5 # https://en.wikipedia.org/wiki/Spaced_repetition
  end

  def virtual_current_successful_timespan(hash)
    algo_simple
    algo_recoveryboost( 
      hash[:current_successful_timespan],
      hash[:ever_successful_timespan],
      hash[:success_count_since_ever],
      hash[:fail_count_since_ever]
    )
  end

  def algo_simple(current_successful_timespan)
    current_successful_timespan
  end

  # return a timespan in [ current_successful_timespan , ever_successful_timespan ]
  def algo_recoveryboost(current_successful_timespan, record_successful_timespan, success_count_since_record, fail_count_since_record)
    q = recoveryboost_weight(current_successful_timespan, record_successful_timespan, success_count_since_record, fail_count_since_record)
    q * record_successful_timespan + (1 - q) * current_successful_timespan
  end

  def recoveryboost_weight(current_successful_timespan, record_successful_timespan, success_count_since_record, fail_count_since_record)
    need = recoveryboost_need(current_successful_timespan, record_successful_timespan)
    relevance = recoveryboost_relevance( success_count_since_record, fail_count_since_record)
    need * relevance
  end

  # return float in [ 0 .. 1 ]
  # 1   when boost is needed      (current_successful_timespan is 0)
  # ... ...
  # 0   when boost is not needed  (current_successful_timespan is close to the record)
  def recoveryboost_need(current_successful_timespan, record_successful_timespan)
    return 0 if record_successful_timespan == 0
    (record_successful_timespan - current_successful_timespan).to_f / record_successful_timespan
  end

  # return float in ] 0 .. 1 ]
  # 1   when boost is relevant     (#fail_since_ever_record << #success_since_ever_record)
  # ... ...
  # 0   when boost is not relevant (#fail_since_ever_record >> #success_since_ever_record)
  def recoveryboost_relevance( success_count_since_record, fail_count_since_record)
    total_eval_since_record = fail_count_since_record + success_count_since_record
    return 1 if total_eval_since_record == 0
    return success_count_since_record.to_f / total_eval_since_record
  end
end
