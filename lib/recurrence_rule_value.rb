require File.expand_path(File.join(File.dirname(__FILE__), "property_value"))

module RiCal
  class RecurrenceRuleValue < PropertyValue 
    
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
          #puts "jan4th = #{jan4th}, jan4th.wday=#{convert_wday(jan4th.wday)}"
          result = jan4th - (convert_wday(jan4th.wday) - convert_wday(wkst))
        else
          # return the date of the wkst day which is greater than or equal to Dec 31 of the prior year
          dec29th = Date.new(year-1, 12, 29)
          result = dec29th + convert_wday(wkst) - convert_wday(dec29th.wday)
        end
        #puts "week_one(#{year}, #{wkst}) is #{result}"
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
      
      Time

      DayNames = %w{SU MO TU WE TH FR SA}
      day_nums = {}
      DayNames.each_with_index { |name, i| day_nums[name] = i }
      DayNums = day_nums

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
      self.freq = value_hash[:freq]
      self.wkst = value_hash[:wkst]
      @count= value_hash[:count]
      @until= value_hash[:until]
      self.interval = value_hash[:interval]
      set_by_lists(value_hash)
    end

    def validate
      @errors = []
      validate_termination
      validate_freq
      validate_interval
      validate_int_by_list(:by_second, (0..59))
      validate_int_by_list(:by_minute, (0..59))
      validate_int_by_list(:by_hour, (0..23))
      validate_int_by_list(:by_month, (1..12))
      validate_by_setpos
      validate_by_day_list
      validate_by_month_day_list
      validate_by_year_day_list
      validate_by_week_no_list
      validate_wkst
    end

    def validate_termination
      errors << "COUNT and UNTIL cannot both be specified" if @count && @until
    end

    def validate_freq
      puts "@freq=#{@freq.inspect}"
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
      puts "errors=#{errors.inspect}"
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

    def validate_by_setpos
      vals = by_list[:by_setpos] || []
      vals.each do |val|
        errors << "#{val} is invalid for by_setpos" unless (-366..-1) === val  || (1..366) === val
      end
      unless vals.empty?
        errors << "by_setpos cannot be used without another by_xxx rule part" unless by_list.length > 1
      end
    end

    def validate_by_day_list
      days = by_list[:by_day] || []
      days.each do |day|
        errors << "#{day.source.inspect} is not a valid day" unless day.valid?
      end
    end

    def validate_by_month_day_list
      days = by_list[:by_month_day] || []
      days.each do |day|
        errors << "#{day.source.inspect} is not a valid month day" unless day.valid?
      end
    end

    def validate_by_year_day_list
      days = by_list[:by_year_day] || []
      days.each do |day|
        errors << "#{day.source.inspect} is not a valid year day" unless day.valid?
      end
    end

    def validate_by_week_no_list
      days = by_list[:by_week_no] || []
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
      @count = count_value
      @until = nil unless count_value.nil?
    end

    def until=(until_value, init=false)
      reset_errors
      @until = until_value
      @count = nil unless until_value.nil?
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
       %w{by_second by_minute by_hour by_day by_month_day by_year_day by_week_no by_month by_setpos}.each do |by_part|
         val = by_list[by_part.to_sym]
         result << "#{by_part.gsub('_','').upcase}=#{[val].flatten.join(',')}" if val
       end
       result << "WKST=#{wkst}" unless wkst == "MO"
       result.join(";")
     end

    private
    def by_list
      @by_list ||= {}
    end

    def set_by_lists(value_hash)
      [:by_second,
        :by_minute,
        :by_hour,
        :by_month,
        :by_setpos
        ].each do |which|
          if val = value_hash[which]
            by_list[which] = [val].flatten
          end
        end
        if val = value_hash[:by_day]
          by_list[:by_day] = [val].flatten.map {|day| RecurringDay.new(day)}
        end
        if val = value_hash[:by_month_day]
          by_list[:by_month_day] = [val].flatten.map {|md| RecurringMonthDay.new(md)}
        end
        if val = value_hash[:by_year_day]
          by_list[:by_year_day] = [val].flatten.map {|yd| RecurringYearDay.new(yd)}
        end
        if val = value_hash[:by_week_no]
          by_list[:by_week_no] = [val].flatten.map {|wkno| RecurringNumberedWeek.new(wkno)}
        end
      end
    end
  end
