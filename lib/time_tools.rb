module TimeTools
  extend self

  def day_distance( from_date, to_date)
    return to_days( to_date - from_date)
  end

  def to_days( seconds)
    return seconds/(60*60*24)
  end 

  def to_hours( seconds)
    return seconds/(60*60)
  end

  def seconds_to seconds, unit
    case unit.to_sym
    when :seconds
      seconds
    when :minutes
      seconds/60
    when :hours
      seconds/(60*60)
    when :days
      seconds/(60*60*24)
    end
  end

  # Choses the decomposition of a timespan expressed in seconds
  # so that the values of the decomposition never exceed the thresholds given in parameters
  # limits = [ hours_limit, minutes_limit, seconds_limit]
  # e.g. with limits[0] == 36:
  # 36 * 60 * 60 - 1 -> { label: "hours", value: [35, 59, 59]}
  # 36 * 60 * 60     -> { label: "days", value: [1, 12, 0, 0]}
  def timespan_decomposition_selector( seconds, limits=[36, 60, 60])
    equivalents = seconds_to_timeunits( seconds)
    hlimits = { days: nil, hours: limits[0], minutes: limits[1], seconds: limits[2] }
    hlimits.keys.reverse.each do |key|
      return { label: key.to_s, value: equivalents[key].values} if (hlimits[key] and equivalents[key].values.first < hlimits[key]) or key == :days
    end
  end

  module TimeUnits
    extend self

    # { "seconds" => 1, :weeks => 1 } returns (1 + 60 * 60 * 24 * 7)
    def timeunits_to_seconds( hash) # smhdw_to_seconds( smhdw_hash
      seconds = 0
      hash.symbolize_keys.each do |key, value|
        if value.present?
          case key
          when :seconds
            seconds += value.to_i
          when :minutes
            seconds += value.to_i * 60
          when :hours
            seconds += value.to_i * 60 * 60
          when :days
            seconds += value.to_i * 60 * 60 * 24
          when :weeks
            seconds += value.to_i * 60 * 60 * 24 * 7
          end
        end
      end
      seconds 
    end

    # Decomposes seconds into:
    # { 
    #   seconds:  { seconds: S}
    #   minutes:  { seconds: S, minutes: M }
    #   hours:    ...
    #   days:
    # }
    def seconds_to_timeunits( seconds)
      second = { seconds: seconds}
      mm, ss = seconds.divmod(60)
      minute = { minutes: mm, seconds: ss}
      hh, mm = mm.divmod(60)
      hour = { hours: hh, minutes: mm, seconds: ss}
      dd, hh = hh.divmod(24)
      day = { days: dd, hours: hh, minutes: mm, seconds: ss}
      ww, dd = dd.divmod(7)
      week = { weeks: ww, days: dd, hours: hh, minutes: mm, seconds: ss}
      return { seconds: second, minutes: minute, hours: hour, days: day, weeks: week}
    end
  end

  extend TimeUnits
end
