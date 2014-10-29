# seq (sequence) - list of consecutive successful evaluations
# mt (maximum timespan) of a sequence - maximal timespan between 2 evaluations of a seq.
module Program::Chronos::Algos::ProvenMax
  include Program::EvaluationHandlerInterface
  include ActionView::Helpers::DateHelper
  extend self

  def fields_and_defaults
    {
      current_timespan:           0,
      record_timespan:            0,
      fail_count_since_record:    0,
      success_count_since_record: 0,
      current_success_count:      0,
      last_evaluation_date:       nil,
      next_evaluation_date:       nil
    }
  end

  def update_state(state, result, eval_date, timebase, capacity_tspan=nil)
    if result
      # review covered timespan
      this_t = (eval_date - (state[:last_evaluation_date] || state[:created_at])).seconds
      # current_timespan
      if this_t > state[:current_timespan]
        state[:current_timespan] = this_t
      end
      # record_timespan, fail_count_since_mt, success_count_since_record
      if this_t > state[:record_timespan]
        state[:record_timespan] = this_t
        state[:fail_count_since_record] = state[:success_count_since_record] = 0
      else
        state[:success_count_since_record] += 1
      end
      # current_success_count
      state[:current_success_count] += 1
      # next_date
      natural_based_delay = next_delay( timebase, state[:current_timespan], state[:current_success_count])
      record_based_delay = next_delay( timebase, state[:record_timespan], state[:current_success_count])

      weight = record_aposteriori_relevance( state[:fail_count_since_record], state[:success_count_since_record])

      virtual_delay = balance( natural_based_delay, record_based_delay, weight)

      state[:next_evaluation_date] = eval_date + virtual_delay.to_i
    else
      # current_timespan
      state[:current_timespan] = 0
      # fail_count_since_record
      state[:fail_count_since_record] += 1
      # current_success_count
      state[:current_success_count] = 0
      # next_date
      state[:next_evaluation_date] = eval_date
    end
    # last_evaluation_date
    state[:last_evaluation_date] = eval_date

    return state
  end

  # Balance the current-sequence-based value with the record-based value.
  def balance(current_value, record_value, weight)
    weight * record_value.to_f + (1 - weight) * current_value.to_f
  end

  ## record_s_count      credibility
  ## 0                   0
  ## 1                   0.5
  ## 2                   0.66
  #def record_confidence( record_success_count)
  #  case record_success_count
  #  when 0 then 0 # impossible cause record => at least 1 success
  #  when 1 then 0.25
  #  when 2 then 0.5
  #  when 3 then 0.75
  #  else 1
  #  end
  #end

  #def record_certitude( record_success_count)
  #  record_success_count
  #end

  ## [ 0 .. +inf [
  #def record_weight( record, timebase)
  #  record.to_f / timebase
  #end

  # Estimate a meaningul weight for the record value in comparision with the current value.
  def record_aposteriori_relevance(fail_count_since_record, success_count_since_record)
    total_count_since_rmt = fail_count_since_record + success_count_since_record
    return 0 if fail_count_since_record == 0 # record should be taken in account only if a fail occured.
    return (success_count_since_record.to_f / total_count_since_rmt) ** 2
  end

  # Time before next review (when only considering the current sequence)
  # 1 to 5 times the current_value, depending on how close to the timebase current_value is.
  def next_delay(timebase, performance, current_success_count)
    case current_success_count
    when 0 then 0
    when 1 then timebase
    when 2 then 2 * timebase
    when 3 then 5 * timebase
    else 5 * performance.to_i
    end
  end

end
