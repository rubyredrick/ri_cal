require 'rubygems'
module RiCal
  class RecurrenceRuleValue < PropertyValue

    class Enumerator
      attr_accessor :start_time, :duration, :next_time, :recurrence_rule
      attr_reader :reset_second, :reset_minute, :reset_hour, :reset_day, :reset_month
      def initialize(recurrence_rule, component, setpos_list)
        self.recurrence_rule = recurrence_rule
        self.start_time = component.default_start_time
        self.duration = component.default_duration
        self.next_time = recurrence_rule.adjust_start(self.start_time)
        @count = 0
        @setpos_list = setpos_list
        @setpos = 1
        @reset_second = recurrence_rule.reset_second || start_time.sec
        @reset_minute = recurrence_rule.reset_minute || start_time.min
        @reset_hour = recurrence_rule.reset_hour || start_time.hour
        @reset_day = recurrence_rule.reset_day || start_time.day
        @reset_month = recurrence_rule.reset_month || start_time.month
        @next_occurrence_count = 0
      end

      def result_hash(date_time_value)
        {:start => date_time_value, :end => nil}
      end
      
      def result_passes_setpos_filter?(result)
        result_setpos = @setpos
        if recurrence_rule.in_same_set?(result, next_time)
          @setpos += 1
        else
          @setpos = 1
        end
        if (result == start_time) || (result > start_time && @setpos_list.include?(result_setpos))
          return true
        else
          return false
        end
      end
      
      def result_passes_filters?(result)
        if @setpos_list
          result_passes_setpos_filter?(result)
        else 
          result >= start_time
        end
      end

      def next_occurrence
        while true
          @next_occurrence_count += 1
          result = next_time
          self.next_time = recurrence_rule.advance(result, self)
          if result_passes_filters?(result)
            @count += 1              
            return recurrence_rule.exhausted?(@count, result) ? nil : result_hash(result)
          end
        end
      end
    end

    class NegativeSetposEnumerator < Enumerator

      def initialize(recurrence_rule, component, setpos_list)
        super
        @current_set = []
        @valids = []
      end

      def next_occurrence
        while true
          result = advance
          if result >= start_time
            @count += 1
            return recurrence_rule.exhausted?(@count, result) ? nil : result_hash(result)
          end
        end
      end

      def advance
        if @valids.empty?
          fill_set
          @valids = @setpos_list.map {|sp| sp < 0 ? @current_set.length + sp : sp - 1}
          current_time_index = @current_set.index(@start_time)
          if current_time_index
            @valids << current_time_index
          end
          @valids = @valids.uniq.sort
        end
        @current_set[@valids.shift]
      end


      def fill_set
        @current_set = [next_time]
        while true
          self.next_time = recurrence_rule.advance(next_time, self)
          if recurrence_rule.in_same_set?(@current_set.last, next_time)
            @current_set << next_time
          else
            return
          end
        end
      end
    end

    def Enumerator.for(recurrence_rule, component, setpos_list)
      if !setpos_list || setpos_list.all? {|setpos| setpos > 1}
        self.new(recurrence_rule, component, setpos_list)
      else
        NegativeSetposEnumerator.new(recurrence_rule, start_time, end_time, setpos_list)
      end
    end

    # Instances of RecurringDay are used to represent values in BYDAY recurrence rule parts
    #
    class RecurringDay 

      DayNames = %w{SU MO TU WE TH FR SA} unless defined? DayNames
      day_nums = {}
      unless defined? DayNums
        DayNames.each_with_index { |name, i| day_nums[name] = i }
        DayNums = day_nums
      end

      attr_reader :source
      def initialize(source, rrule)
        @source = source
        @rrule = rrule
        wd_match = source.match(/([+-]?\d*)(SU|MO|TU|WE|TH|FR|SA)/)
        if wd_match
          @day, @ordinal = wd_match[2], wd_match[1]
        end
      end

      def valid?
        !@day.nil?
      end

      def ==(another)
        self.class === another && to_a = another.to_a
      end

      def to_a
        [@day, @ordinal]
      end

      def to_s
        "#{@ordinal}#{@day}"
      end

      def ordinal_match(date_or_time)
        if @ordinal == ""
          true
        else
          n = @ordinal.to_i
          if @rrule.freq == "YEARLY"
            date_or_time.nth_wday_in_year?(n, DayNums[@day]) 
          else
            date_or_time.nth_wday_in_month?(n, DayNums[@day])
          end
        end
      end

      # Determine if a particular date, time, or date_time is included in the recurrence
      def include?(date_or_time)
        date_or_time.wday == DayNums[@day] && ordinal_match(date_or_time)
      end
    end

    class RecurringNumberedSpan
      attr_reader :source
      def initialize(source)
        @source = source
      end

      def valid?
        (1..last).include?(source) || (-last..-1).include?(source)
      end

      def  ==(another)
        self.class == another.class && source == another.source
      end

      def to_s
        source.to_s
      end
    end

    # Instances of RecurringMonthDay represent BYMONTHDAY parts in recurrence rules
    class RecurringMonthDay < RecurringNumberedSpan

      def last
        31
      end

      def target_for(date_or_time)
        if @source > 0
          @source
        else
          date_or_time.days_in_month + @source + 1
        end
      end

      def include?(date_or_time)
        date_or_time.mday == target_for(date_or_time)
      end
    end

    class RecurringYearDay < RecurringNumberedSpan

      def last
        366
      end
      
      def leap_year?(year)
        year % 4 == 0 && (year % 400 == 0 || year % 100 != 0)
      end 
      

      def length_of_year(year)
        leap_year?(year) ? 366 : 365
      end 

      def include?(date_or_time)
        if @source > 0
          target = @source
        else
          target = length_of_year(date_or_time.year) + @source + 1
        end
        date_or_time.yday == target
      end
    end

    class RecurringNumberedWeek < RecurringNumberedSpan
      def last
        53
      end

      def include?(date_or_time, wkst=1)
        date_or_time.iso_week_num(wkst) == @source
      end
    end

    attr_reader :count, :until

    def initialize(value_hash)
      super
      initialize_from_hash(value_hash) unless value_hash[:value]
    end

    def initialize_from_hash(value_hash)
      self.freq = value_hash[:freq]
      self.wkst = value_hash[:wkst]
      set_count(value_hash[:count])
      set_until(value_hash[:until])
      self.interval = value_hash[:interval]
      set_by_lists(value_hash)
    end

    def value=(string)
      if string
        @value = string
        parts = string.split(";")
        value_hash = parts.inject({}) { |hash, part| add_part_to_hash(hash, part) }
        initialize_from_hash(value_hash)
      end
    end

    def add_part_to_hash(hash, part)
      part_name, value = part.split("=")
      puts "part=#{part.inspect}" unless part_name
      attribute = part_name.downcase.to_sym
      errors << "Repeated rule part #{attribute} last occurrence was used" if hash[attribute]
      case attribute
      when :freq, :wkst
      when :until
        value = PropertyValue.date_or_date_time(:value => value)
      when :interval, :count
        value = value.to_i
      when :bysecond, :byminute, :byhour, :bymonthday, :byyearday, :byweekno, :bymonth, :bysetpos
        value = value.split(",").map {|int| int.to_i} 
      when :byday
        value = value.split(",")
      else
        errors << "Invalid rule part #{part}"
      end
      hash[attribute] = value
      hash
    end

    def validate
      @errors = []
      validate_termination
      validate_freq
      validate_interval
      validate_int_by_list(:bysecond, (0..59))
      validate_int_by_list(:byminute, (0..59))
      validate_int_by_list(:byhour, (0..23))
      validate_int_by_list(:bymonth, (1..12))
      validate_bysetpos
      validate_byday_list
      validate_bymonthday_list
      validate_byyearday_list
      validate_byweekno_list
      validate_wkst
    end

    def validate_termination
      errors << "COUNT and UNTIL cannot both be specified" if @count && @until
    end

    def validate_freq
      if @freq
        unless %w{
          SECONDLY MINUTELY HOURLY DAILY
          WEEKLY MONTHLY YEARLY
          }.include?(@freq.upcase)
          errors <<  "Invalid frequency '#{@freq}'"
        end
      else
        errors << "RecurrenceRule must have a value for FREQ"
      end
    end

    def validate_interval
      if @interval
        errors << "interval must be a positive integer" unless @interval > 0
      end
    end

    def validate_wkst
      errors << "#{wkst.inspect} is invalid for wkst" unless %w{MO TU WE TH FR SA SU}.include?(wkst)
    end

    def validate_int_by_list(which, test)
      vals = by_list[which] || []
      vals.each do |val|
        errors << "#{val} is invalid for #{which}" unless test === val
      end
    end

    def validate_bysetpos
      vals = by_list[:bysetpos] || []
      vals.each do |val|
        errors << "#{val} is invalid for bysetpos" unless (-366..-1) === val  || (1..366) === val
      end
      unless vals.empty?
        errors << "bysetpos cannot be used without another by_xxx rule part" unless by_list.length > 1
      end
    end

    def validate_byday_list
      days = by_list[:byday] || []
      days.each do |day|
        errors << "#{day.source.inspect} is not a valid day" unless day.valid?
      end
    end

    def validate_bymonthday_list
      days = by_list[:bymonthday] || []
      days.each do |day|
        errors << "#{day.source.inspect} is not a valid month day" unless day.valid?
      end
    end

    def validate_byyearday_list
      days = by_list[:byyearday] || []
      days.each do |day|
        errors << "#{day.source.inspect} is not a valid year day" unless day.valid?
      end
    end

    def validate_byweekno_list
      days = by_list[:byweekno] || []
      days.each do |day|
        errors << "#{day.source.inspect} is not a valid week number" unless day.valid?
      end
    end

    def freq=(freq_value)
      reset_errors
      @freq = freq_value
    end

    def freq
      @freq.upcase
    end

    def wkst
      @wkst || 'MO'
    end

    def wkst_day
      @wkst_day ||= (%w{SU MO TU WE FR SA}.index(wkst) || 1)
    end

    def wkst=(value)
      reset_errors
      @wkst = value
      @wkst_day = nil
    end

    def count=(count_value)
      reset_errors
      set_count(count_value)
      @until = nil unless count_value.nil?
    end

    def set_count(count_value)
      @count = count_value
    end

    def until=(until_value, init=false)
      reset_errors
      set_until
      @count = nil unless until_value.nil?
    end

    def set_until(until_value)
      @until = until_value && until_value.to_ri_cal_date_time_value
    end

    def interval
      @interval ||= 1
    end

    def interval=(interval_value)
      reset_errors
      @interval = interval_value
    end

    def errors
      @errors ||= []
    end

    def reset_errors
      @errors = nil
    end

    def valid?
      validate if @errors.nil?
      errors.empty?
    end

    def to_ical
      result = ["FREQ=#{freq}"]
      result << "COUNT=#{count}" if count
      result << "INTERVAL=#{interval}" unless interval == 1
      %w{bysecond byminute byhour byday bymonthday byyearday byweekno bymonth bysetpos}.each do |by_part|
        val = by_list[by_part.to_sym]
        result << "#{by_part.upcase}=#{[val].flatten.join(',')}" if val
      end
      result << "WKST=#{wkst}" unless wkst == "MO"
      result.join(";")
    end

    # if the recurrence rule has a bysetpos part we need to search starting with the
    # first time in the frequency period containing the start time specified by DTSTART
    def adjust_start(start_time)
      if by_list[:bysetpos]
        case freq
        when "SECONDLY"
          start_time
        when "MINUTELY"
          start_time.change(:seconds => 0)
        when "HOURLY"
          start_time.change(
          :minutes => 0, 
          :seconds => start_time.sec
          )
        when "DAILY"
          start_time.change(
          :hour => 0,
          :minutes => start_time.min, 
          :seconds => start_time.sec
          )
        when "WEEKLY"
          start_of_week(time)
        when "MONTHLY"
          start_time.change(
          :day => 1, 
          :hour => start_time.hour, 
          :minutes => start_time.min,
          :seconds => start_time.sec
          )
        when "YEARLY"
          start_time.change(
          :month => 1,
          :day => start_time.day,
          :hour => start_time.hour,
          :minutes => start_time.min,
          :seconds => start_time.sec
          )
        end
      else
        start_time
      end
    end

    def enumerator(component)
      Enumerator.for(self, component, by_list[:bysetpos])
    end

    def exhausted?(count, time)
      (@count && count > @count) || (@until && (time > @until))
    end

    def start_of_week(time)
      time.advance(:days => - (wkst_day - time.wday + 7) % 7)
    end

    def in_same_set?(time1, time2)
      case freq
      when "SECONDLY"
        [time1.year, time1.month, time1.day, time1.hour, time1.min, time1.sec] ==
        [time2.year, time2.month, time2.day, time2.hour, time2.min, time2.sec] 
      when "MINUTELY"
        [time1.year, time1.month, time1.day, time1.hour, time1.min] ==
        [time2.year, time2.month, time2.day, time2.hour, time2.min] 
      when "HOURLY"
        [time1.year, time1.month, time1.day, time1.hour] ==
        [time2.year, time2.month, time2.day, time2.hour] 
      when "DAILY"
        [time1.year, time1.month, time1.day] ==
        [time2.year, time2.month, time2.day] 
      when "WEEKLY"
        sow1 = start_of_week(time1)
        sow2 = start_of_week(time2)
        [sow1.year, sow1.month, sow1.day] ==
        [sow2.year, sow2.month, sow2.day] 
      when "MONTHLY"
        [time1.year, time1.month] ==
        [time2.year, time2.month] 
      when "YEARLY"
        time1.year == time2.year 
      end
    end


    def advance(time, enumerator)
      time = advance_seconds(time, enumerator)     
      while exclude_time_by_rule?(time) && (!@until || (time <= @until))
        time = advance_seconds(time, enumerator)
      end
      time
    end

    # determine if time should be excluded due to by rules
    def exclude_time_by_rule?(time)
      #TODO - this is overdoing it in cases like by_month with a frequency longer than a month
      exclude_time_by_value_rule?(:bysecond, time.sec) ||
      exclude_time_by_value_rule?(:byminute, time.min) ||
      exclude_time_by_value_rule?(:byhour, time.hour) ||
      exclude_time_by_value_rule?(:bymonth, time.month) ||
      exclude_time_by_inclusion_rule?(:byday, time) ||
      exclude_time_by_inclusion_rule?(:bymonthday, time) ||
      exclude_time_by_inclusion_rule?(:byyearday, time) ||
      exclude_time_by_inclusion_rule?(:byweekno, time)
    end

    def exclude_time_by_value_rule?(rule_selector, value)
      valid = by_list[rule_selector]
      valid && !valid.include?(value)
    end

    def exclude_time_by_inclusion_rule?(rule_selector, time)
      valid = by_list[rule_selector]
      valid && !valid.any? {|rule| rule.include?(time)}
    end

    def reset_value(which)
      if list = by_rule_list(which)
        list.first #Note that [].first => nil
      else
        nil
      end
    end

    def reset_second
      reset_value(:bysecond)
    end

    def reset_minute
      reset_value(:byminute)
    end

    def reset_hour
      reset_value(:byhour)
    end

    def reset_day
      if @by_list && (@by_list[:byday] || @by_list[:bymonthday] || @by_list[:byyearday])
        1
      else
        nil
      end
    end

    def by_rule_list(which)
      if @by_list
        @by_list[which]
      else
        nil
      end
    end

    def reset_month
      reset_value(:bymonth)
    end

    def advance_seconds(time, enumerator)
      res = advance_seconds1(time, enumerator)
      debugger unless DateTimeValue === res
      res
    end

    def advance_minutes(time, enumerator)
      res = advance_minutes1(time, enumerator)
      debugger unless DateTimeValue === res
      res
    end

    def advance_hours(time, enumerator)
      res = advance_hours1(time, enumerator)
      debugger unless DateTimeValue === res
      res
    end

    def advance_days(time, enumerator)
      res = advance_days1(time, enumerator)
      debugger unless DateTimeValue === res
      res
    end

    def advance_weeks(time, enumerator)
      res = advance_weeks1(time, enumerator)
      debugger unless DateTimeValue === res
      res
    end


    def advance_months(time, enumerator)
      res = advance_months1(time, enumerator)
      debugger unless DateTimeValue === res
      res
    end

    def advance_seconds1(time, enumerator)
      if freq == 'SECONDLY'
        time.advance(:seconds => interval)
      elsif seconds_list = by_rule_list(:bysecond)
        next_second = seconds_list.find {|sec| sec > time.sec}
        if next_second
          time.change(:sec => next_second)
        else
          advance_minutes(
          time.change(:sec => enumerator.reset_second),
          enumerator
          )
        end
      else
        advance_minutes(time, enumerator)
      end
    end

    def advance_minutes1(time, enumerator)
      if freq == 'MINUTELY'
        time.advance(:minutes => interval)
      elsif minutes_list = by_rule_list(:byminute)
        next_minute = minutes_list.find {|min| min > time.min}
        if next_minute
          time.change(:min => next_minute, :sec => time.sec)
        else
          advance_hours(
          time.change(:min => minutes_list.first, :sec => enumerator.reset_second),
          enumerator
          )
        end
      else
        advance_hours(time, enumerator)
      end
    end

    def advance_hours1(time, enumerator, debug=false)
      if freq == 'HOURLY'
        time.advance(:hours => interval)
      elsif hours_list = by_rule_list(:byhour)
        next_hour = hours_list.find {|hr| hr > time.hour}
        if next_hour
          time.change(:hour => next_hour, :min => time.min, :sec => time.sec)
        else
          advance_days(
          time.change(:hour => enumerator.reset_hour, :min => enumerator.reset_minute, :sec => enumerator.reset_second),
          enumerator
          )
        end
      else
        advance_days(time, enumerator)
      end
    end

    def advance_days1(time, enumerator, debug = false)
      if freq == 'DAILY'
        result = time.advance(:days => interval)
        result
      elsif by_rule_list(:byday) || 
        by_rule_list(:bymonthday) ||
        by_rule_list(:byyearday)
        new_time = time.advance(:days => 1)
        if freq == "WEEKLY" && interval > 1 && new_time.wday == wkst_day
          new_time.advance(:weeks => interval - 1)
        elsif freq == "MONTHLY" && interval > 1 && new_time.month != time.month
          new_time.advance(:months => interval - 1)
        elsif freq == "YEARLY" && interval > 1 && new_time.year != time.year
          new_time.advance(:years => interval - 1)
        else
          new_time
        end
      else
        advance_weeks(time, enumerator)
      end
    end

    def advance_weeks1(time, enumerator)
      if freq == 'WEEKLY'
        time.advance(:days => 7 * interval)
      else
        advance_months(time, enumerator)
      end
    end

    def advance_months1(time, enumerator)
      if freq == 'MONTHLY'
        return time.advance(:months => interval)
      elsif months_list = by_rule_list(:bymonth)
        next_month = months_list.find {|month| month > time.month}
        if next_month
          return time.change(
          :month => next_month, 
          :day => time.day, 
          :hour => time.hour,
          :min => time.min,
          :sec => time.sec
          )
        end
      end
      year_increment = freq == "YEARLY" ? interval : 1
      time.change(
      :year => time.year + year_increment,
      :month => enumerator.reset_month, 
      :day => enumerator.reset_day, 
      :hour => enumerator.reset_hour, 
      :min => enumerator.reset_minute,
      :sec => enumerator.reset_second
      )
    end

    private

    def by_list
      @by_list ||= {}
    end

    def set_by_lists(value_hash)
      [:bysecond,
        :byminute,
        :byhour,
        :bymonth,
        :bysetpos
        ].each do |which|
          if val = value_hash[which]
            by_list[which] = [val].flatten.sort
          end
        end
        if val = value_hash[:byday]
          by_list[:byday] = [val].flatten.map {|day| RecurringDay.new(day, self)}
        end
        if val = value_hash[:bymonthday]
          by_list[:bymonthday] = [val].flatten.map {|md| RecurringMonthDay.new(md)}
        end
        if val = value_hash[:byyearday]
          by_list[:byyearday] = [val].flatten.map {|yd| RecurringYearDay.new(yd)}
        end
        if val = value_hash[:byweekno]
          by_list[:byweekno] = [val].flatten.map {|wkno| RecurringNumberedWeek.new(wkno)}
        end
      end
    end
  end
