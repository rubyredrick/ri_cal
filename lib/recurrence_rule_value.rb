require File.expand_path(File.join(File.dirname(__FILE__), "property_value"))

require 'rubygems'
require 'activesupport'

module RiCal
  class RecurrenceRuleValue < PropertyValue
    
    class OccurrenceEnumerator
      attr_accessor :next_time, :recurrence_rule
      def initialize(recurrence_rule, start_time)
        self.recurrence_rule = recurrence_rule
        # datetime conversion stolen from ActiveSupport time#to_date_time
        self.next_time = start_time.to_datetime
        @count = 0
      end

      def next_occurrence
        result = next_time
        self.next_time = compute_next_occurrence(result)
        @count += 1
        if recurrence_rule.exhausted?(@count, result)
          nil
        else
          result
        end
      end
      
      def compute_next_occurrence(time)
        recurrence_rule.advance_by_interval(time)
      end
      
    end
    
    module MonthLengthCalculator
      def leap_year(year)
        year % 4 == 0 && (year % 400 == 0 || year % 100 != 0)
      end 

      def days_in_month(date_or_time)
        year = date_or_time.year
        raw = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][date_or_time.month]
        date_or_time.month == 2 && leap_year(year) ? raw + 1 : raw
      end
    end
    
    module WeekNumCalculator
      # From RFC 2445 page 43:
      # A week is defined as a seven day period, starting on the day of the week defined to be the
      # week start (see WKST). Week number one of the calendar year is the first week which contains 
      # at least four (4) days in that calendar
      # year.
      # 
      # Note that wkst uses the ruby definition, with Sunday = 0 
      #
      # A good article about calculating ISO week number is at
      # http://www.boyet.com/Articles/PublishedArticles/CalculatingtheISOweeknumb.html
      #
      # RFC 2445 generalizes the notion of ISO week by allowing the start of the week to vary.
      # In order to adopt the algorithm in the referenced article, we must determine, for each
      # wkst value, the day in January which must be contained in week 1 of the year.
      # 
      # For a given wkst week 1 for a year is the first week which
      #   1) Starts with a day with a wday of wkst
      #   2) Contains a majority (4 or more) of days in that year
      # 
      # If end of prior Dec, start of Jan          Week 1 starts on For WKST =

      # MO TU WE TH FR SA SU MO TU WE TH FR SA SU  MO    TU    WE    TH    FR    SA    SU      
      # 01 02 03 04 05 06 07 08 09 10 11 12 13 14 01-07 02-08 03-09 04-10 05-11 06-12 07-13
      # 31 01 02 03 04 05 06 07 08 09 10 11 12 13 31-06 01-07 02-08 03-09 04-10 05-11 06-12
      # 30 31 01 02 03 04 05 06 07 08 09 10 11 12 30-05 31-06 01-07 02-08 03-09 04-10 05-11
      # 29 30 31 01 02 03 04 05 06 07 08 09 10 11 29-04 30-05 31-06 01-07 02-08 03-09 04-10
      # 28 29 30 31 01 02 03 04 05 06 07 08 09 10 04-10 29-04 30-05 31-06 01-07 02-08 03-09
      # 27 28 29 30 31 01 02 03 04 05 06 07 08 09 03-09 04-10 29-04 30-05 31-06 01-07 02-08
      # 26 27 28 29 30 31 01 02 03 04 05 06 07 08 02-08 03-09 04-10 29-04 30-05 31-06 01-07
      # 25 26 27 28 29 30 31 01 02 03 04 05 06 07 01-07 02-08 03-09 04-10 29-04 30-05 31-06
      #                     Week 1 must contain     4     4     4     4     ?     ?     ?  
      #
      # So for a wkst of FR, SA, or SU, there is no date which MUST be contained in the 1st week
      # We'll have to brute force that

      def week_one(year, wkst)
        if (1..4).include?(wkst)
          # return the date of the wkst day which is less than or equal to jan4th
          jan4th = Date.new(year, 1, 4)
          result = jan4th - (convert_wday(jan4th.wday) - convert_wday(wkst))
        else
          # return the date of the wkst day which is greater than or equal to Dec 31 of the prior year
          dec29th = Date.new(year-1, 12, 29)
          result = dec29th + convert_wday(wkst) - convert_wday(dec29th.wday)
        end
        result
      end
      
      def convert_wday(wday)
        wday == 0 ? 7 : wday
      end
      
      def iso_week(date_or_time, wkst)
        debug = wkst > 1 
        iso_year = date_or_time.year
        date = Date.new(date_or_time.year, date_or_time.month, date_or_time.mday)
        if (date > Date.new(iso_year, 12, 29))
          week_one_start = week_one(iso_year + 1, wkst)
          if date < week_one_start
            week_one_start = week_one(iso_year, wkst)
          else
            iso_year += 1
          end
        else
          week_one_start = week_one(iso_year, wkst)
          if (date < week_one_start)
            iso_year -= 1
            week_one_start = week_one(iso_year, wkst)
          end
        end
        [iso_year, (date - week_one_start).to_i / 7 + 1]
      end
      
      def week_num(date_or_time, wkst, debug=false)
        iso_week(date_or_time, wkst)[1]
      end
    end

    # Instances of RecurringDay are used to represent values in BYDAY recurrence rule parts
    #
    class RecurringDay 
      
      include MonthLengthCalculator 
      
      DayNames = %w{SU MO TU WE TH FR SA} unless defined? DayNames
      day_nums = {}
      unless defined? DayNums
        DayNames.each_with_index { |name, i| day_nums[name] = i }
        DayNums = day_nums
      end

      attr_reader :source
      def initialize(source)
        @source = source
        wd_match = source.match(/([+-]?\d*)(SU|MO|TU|WE|TH|FR|SA)/)
        if wd_match
          @day, @ord = wd_match[2], wd_match[1]
        end
      end

      def valid?
        !@day.nil?
      end

      def ==(another)
        self.class === another && to_a = another.to_a
      end

      def to_a
        [@day, @ord]
      end

      def to_s
        "#{@ord}#{@day}"
      end

      def order_match(date_or_time)
        if @ord == ""
          true
        else
          n = @ord.to_i
          first_of_month = Date.new(date_or_time.year, date_or_time.month, 1)
          first_in_month = first_of_month + (DayNums[@day] - first_of_month.wday)
          first_in_month += 7 if first_in_month.month != first_of_month.month
          if n > 0
            target = first_in_month + (7*(n - 1))
          else
            possible = first_in_month +  21
            possible += 7 while possible.month == first_in_month.month
            last_in_month = possible - 7
            target = last_in_month - (7*(n.abs - 1))
          end
          Date.new(date_or_time.year, date_or_time.mon, date_or_time.day) == target
        end
      end

      # Determine if a particular date, time, or date_time is included in the recurrence
      def include?(date_or_time)
        date_or_time.wday == DayNums[@day] && order_match(date_or_time)
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
      
      include MonthLengthCalculator
      
      def last
        31
      end
      
      def target_for(date_or_time)
        if @source > 0
          @source
        else
          days_in_month(date_or_time) + @source + 1
        end
      end
      
      def include?(date_or_time)
        date_or_time.mday == target_for(date_or_time)
      end
    end

    class RecurringYearDay < RecurringNumberedSpan
      
      include MonthLengthCalculator
      
      def last
        366
      end
            
      def length_of_year(year)
        leap_year(year) ? 366 : 365
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
      include WeekNumCalculator
      
      def last
        53
      end
      
      def include?(date_or_time, wkst=1)
        week_num(date_or_time, wkst) == @source
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

    def wkst=(value)
      reset_errors
      @wkst = value
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
      @until = date_time_from_value(until_value)
    end
    
    def date_time_from_value(value)
      if value
         value.to_datetime
      else
        nil
      end
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

    def enumerator(start_time)
      OccurrenceEnumerator.new(self, start_time)
    end
    
    def exhausted?(count, time)
      (@count && count > @count) || (@until && time > @until)
    end
    
    def advance_by_interval(time)
      time = advance_time_by_interval_once(time)
      while exclude_time_by_rule?(time) && (!@until || time <= @until)
        time = advance_time_by_interval_once(time)
      end
      time
    end
    
    # determine if time should be excluded due to by rules
    def exclude_time_by_rule?(time)
      exclude_time_by_month?(time)
    end
    
    def exclude_time_by_month?(time)
      valid_months = by_list[:bymonth]
      valid_months && !valid_months.include?(time.month)
    end

    def advance_time_by_interval_once(time)
      case freq
      when "DAILY"
        time.advance(:days => interval)
      when "WEEKLY"
        time.advance(:weeks => interval)
      when "SECONDLY"
        time.advance(:seconds => interval)
      when "MINUTELY"
        time.advance(:minutes => interval) 
      when "HOURLY"
        time.advance(:hours => interval)
      when "DAILY"
        time.advance(:days => interval)
      when "WEEKLY"
        time.advance(:weeks => interval)
      when "MONTHLY"
        time.advance(:months => interval) 
      when "YEARLY"
        time.advance(:years => interval)
      end
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
            by_list[which] = [val].flatten
          end
        end
        if val = value_hash[:byday]
          by_list[:byday] = [val].flatten.map {|day| RecurringDay.new(day)}
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
