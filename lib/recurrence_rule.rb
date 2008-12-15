module RiCal
  class RecurrenceRule
    
    attr_reader :count, :until

    def initialize(value_hash)
      self.freq = value_hash[:freq]
      @count= value_hash[:count]
      @until= value_hash[:until]
      self.interval = value_hash[:interval]
      set_by_lists(value_hash)
    end
    
    def validate
      @errors = []
      errors << "COUNT and UNTIL cannot both be specified" if @count && @until
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
      if @interval
        errors << "interval must be a positive integer" unless @interval > 0 
      end
    end
    
    def freq=(freq_value)
      reset_errors
      @freq = freq_value
    end
    
    def freq
      @freq.upcase
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
    
    private
    def by_list
      @by_list ||= {}
    end
    
    def set_by_lists(value_hash)
      [
        :by_second,
        :by_minute,
        :by_hour,
        :by_day,
        :by_month_day,
        :by_year_day,
        :by_week_no,
        :by_month,
        :by_setpos
        ].each do |which|
          if val = value_hash[which]
            by_list[which] = [val].flatten
          end
        end
      end
    end
end
