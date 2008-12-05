require File.join(File.dirname(__FILE__), 'vtimezone')

# A wrapper class for a Timezone implemented by the TZInfo Gem
# (or Rails)
class RiCal::TZInfoVtimezone < RiCal::Vtimezone
  attr_reader :tzinfo_timezone

  def initialize(tzinfo_timezone)
    @tzinfo_timezone = tzinfo_timezone
  end
  
  def local_to_utc(time)
    @tzinfo_timezone.local_to_utc(time)
  end
  
  def identifier
    @tzinfo_timezone.identifier
  end

  def to_rfc2445_string(utc_start, utc_end)
    result = ["BEGIN:VTIMEZONE","TZID;X-RICAL-TZSOURCE=TZINFO:#{identifier}"]
    period = tzinfo_timezone.period_for_utc(utc_start)
    prev_period = tzinfo_timezone.period_for_utc(period.utc_start - 1)
    while period && period.utc_start < utc_end
      add_period(result, period, prev_period)
      prev_period = period
      period = tzinfo_timezone.period_for_utc(period.utc_end + 1)
    end 
    result << "END:VTIMEZONE\n"
    result.join("\n")
  end

  def add_period(result, this_period, prev_period)
    if this_period.dst?
      which = 'DAYLIGHT'
      offset_from  = this_period.utc_offset
      offset_to = this_period.utc_total_offset
    else
      which = 'STANDARD'
    end
    onset = this_period.local_start.strftime("%Y%m%dT%H%M%S")
    result << "BEGIN:#{which}"
    result << "DTSTART:#{onset}"
    result << "RDATE:#{onset}"
    result << "TZOFFSETFROM:#{format_rfc2445_offset(prev_period.utc_total_offset)}"
    result << "TZOFFSETTO:#{format_rfc2445_offset(this_period.utc_total_offset)}"
    result << "TZNAME:#{this_period.abbreviation}"
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