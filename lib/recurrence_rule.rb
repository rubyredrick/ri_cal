module RiCal
  class RecurrenceRule
    
    class RecurringDay
      
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
    
    class RecurringMonthDay < RecurringNumberedSpan 
      def last
        31
      end
    end
    
    class RecurringYearDay < RecurringNumberedSpan 
      def last
        366
      end
    end
    
    class RecurringNumberedWeek < RecurringNumberedSpan 
      def last
        53
      end
    end
    
    attr_reader :count, :until

    def initialize(value_hash)
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
