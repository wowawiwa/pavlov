module Program::Chronos::Algos::Legacy
  include Program::EvaluationHandlerInterface
  extend self

  private

  def fields_and_defaults
    {
      current_successful_timespan:  0,
      ever_successful_timespan:     0,
      fail_count_since_ever:        0,
      success_count_since_ever:     0,
      last_evaluation_date:         nil,
      next_evaluation_date:         nil
    }
  end

  def update_state(state, result, eval_date, rhythm_tspan, capacity_tspan)
    if result
      state[:current_successful_timespan] = state[:current_successful_timespan] + (eval_date - (state[:last_evaluation_date] || state[:created_at])).round
      if state[:current_successful_timespan] >= state[:ever_successful_timespan]
        state[:ever_successful_timespan] = state[:current_successful_timespan]
        state[:success_count_since_ever] = 0
        state[:fail_count_since_ever] = 0
      else
        state[:success_count_since_ever] += 1
      end
      #state[:next_evaluation_date] = eval_date + [ capacity_tspan, rhythm_tspan, Program::Chronos::NextStep.next_step(self.attributes) ].max
    else
      state[:current_successful_timespan] = 0
      state[:fail_count_since_ever] += 1
      state[:next_evaluation_date] = eval_date
    end
    state[:last_evaluation_date] = eval_date

    return state
  end
end
