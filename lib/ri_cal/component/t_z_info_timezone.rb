# A wrapper class for a Timezone implemented by the TZInfo Gem
# (or by Rails)
class RiCal::Component::TZInfoTimezone < RiCal::Component::Timezone

  class Period

    def initialize(which, this_period, prev_period)
      @which = which
      @onset = this_period.local_start.strftime("%Y%m%dT%H%M%S")
      @offset_from = format_rfc2445_offset(prev_period.utc_total_offset)
      @offset_to = format_rfc2445_offset(this_period.utc_total_offset)
      @abbreviation = this_period.abbreviation
      @rdates = []
    end

    def add_period(this_period)
      @rdates << this_period.local_start.strftime("%Y%m%dT%H%M%S")
    end


    def format_rfc2445_offset(seconds) # :nodoc:
      abs_seconds = seconds.abs
      h = (abs_seconds/3600).floor
      m = (abs_seconds - (h * 3600))/60
      h *= -1 if seconds < 0
      sprintf("%+03d%02d", h, m)
    end

    def emit
      result = []
      result << "BEGIN:#{@which}"
      result << "DTSTART:#{@onset}"
      result << "RDATE:#{@rdates.join(",")}"
      result << "TZOFFSETFROM:#{@offset_from}"
      result << "TZOFFSETTO:#{@offset_to}"
      result << "TZNAME:#{@abbreviation}"
      result << "END:#{@which}"
    end

    def self.daylight_period(this_period, previous_period)
      @daylight_period ||= new("DAYLIGHT", this_period, previous_period)
    end

    def self.standard_period(this_period, previous_period)
      @standard_period ||= new("STANDARD", this_period, previous_period)
    end

    def self.reset
      @dst_period = @std_period = @previous_period = nil
    end

    def self.log_period(period)
      @periods ||= []
      @periods << period unless @periods.include?(period)
    end

    def self.add_period(this_period)
      if @previous_period
        if this_period.dst?
          period = daylight_period(this_period, @previous_period)
        else
          period = standard_period(this_period, @previous_period)
        end
        period.add_period(this_period)
        log_period(period)
      end
      @previous_period = this_period
    end

    def self.emit_periods
      @periods.map {|period| period.emit}.flatten.join("\n")
    end
  end

  attr_reader :tzinfo_timezone

  def initialize(tzinfo_timezone)
    @tzinfo_timezone = tzinfo_timezone
  end

  def local_to_utc(time)
    @tzinfo_timezone.local_to_utc(time)
  end
  
  def utc_to_local(time)
    @tzinfo_timezone.utc_to_local(time)
  end

  def identifier
    @tzinfo_timezone.identifier
  end

  def to_rfc2445_string(utc_start, utc_end)
    result = ["BEGIN:VTIMEZONE","TZID;X-RICAL-TZSOURCE=TZINFO:#{identifier}"]
    Period.reset
    period = tzinfo_timezone.period_for_utc(utc_start)
    # start with the period before the one containing utc_start
    period = tzinfo_timezone.period_for_utc(period.utc_start - 1)
    while period && period.utc_start < utc_end
      Period.add_period(period)
      period = tzinfo_timezone.period_for_utc(period.utc_end + 1)
    end
    result << Period.emit_periods
    result << "END:VTIMEZONE\n"
    result.flatten.join("\n")
  end
end