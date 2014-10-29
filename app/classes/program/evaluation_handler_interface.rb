module Program::EvaluationHandlerInterface
  extend self

  # update_state_args: before_state, ...
  def run_iteration(*update_state_args)
    return finalize( update_state( init(update_state_args.shift), *update_state_args))
  end

  #private TODO

  # Format the hash keys and set default values
  def init(state)
    fields_and_defaults.merge!( state.symbolize_keys.compact)
  end

  def finalize(state)
    state.select{|k| k.in? fields_and_defaults.keys }.stringify_keys
  end

  def fields_and_defaults(*args)
    raise "To implement - Return a hash which keys are the fields to be updated and values their default values (if they are nil)."
  end

  def update_state(*args)
    raise "To implement - Return the hash with the updated values."
  end
end
