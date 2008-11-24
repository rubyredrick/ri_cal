require 'tzinfo'

module TZInfo
  class Timezone
    def to_rfc2445_string(utc_start, utc_end)
      result = ["BEGIN:VTIMEZONE","TZID:#{identifier}"]
      period = period_for_utc(utc_start)
      prev_period = period_for_utc(period.utc_start - 1)
      while period && period.utc_start < utc_end
        period.add_rfc2445_period(result, prev_period)
        prev_period = period
        period = period_for_utc(period.utc_end + 1)
      end 
      result << "END:VTIMEZONE\n"
      result.join("\n")
    end   
  end
  
  class TimezonePeriod
    def add_rfc2445_period(result, prev_period)
      if dst?
        which = 'DAYLIGHT'
        offset_from  = utc_offset
        offset_to = utc_total_offset
      else
        which = 'STANDARD'
      end
      onset = local_start.strftime("%Y%m%dT%H%M%S")
      result << "BEGIN:#{which}"
      result << "DTSTART:#{onset}"
      result << "RDATE:#{onset}"
      result << "TZOFFSETFROM:#{format_rfc2445_offset(prev_period.utc_total_offset)}"
      result << "TZOFFSETTO:#{format_rfc2445_offset(utc_total_offset)}"
      result << "TZNAME:#{abbreviation}"
      result << "END:#{which}"
    end
    
    def format_rfc2445_offset(seconds)
      abs_seconds = seconds.abs
      h = (abs_seconds/3600).floor
      m = (abs_seconds - (h * 3600))/60
      h *= -1 if seconds < 0
      sprintf("%+03d%02d", h, m)
    end
  end
end   
