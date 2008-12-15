module RiCal
  class RecurrenceRule
    
    attr_reader :count, :until
    def initialize(value_hash)
      self.freq = value_hash[:freq]
      @count= value_hash[:count]
      @until= value_hash[:until]
      self.interval = value_hash[:interval]
      set_by_lists(value_hash)
      errors << "COUNT and UNTIL cannot both be specified" if @count && @until
    end
    
    def freq=(freq_value)
      @freq = freq_value
      if freq_value
        unless %w{
          SECONDLY MINUTELY HOURLY DAILY
          WEEKLY MONTHLY YEARLY
          }.include?(freq_value.upcase)
          errors <<  "Invalid frequency '#{freq_value}'" 
        end
      else
        errors << "RecurrenceRule must have a value for FREQ" 
      end
    end
    
    def freq
      @freq.upcase
    end
    
    def count=(count_value)
      @count = count_value
      @until = nil unless count_value.nil?
    end
    
    def until=(until_value, init=false)
      @until = until_value
      @count = nil unless until_value.nil?
    end
    
    def interval
      @interval ||= 1
    end 
    
    def interval=(interval_value)
      @interval = interval_value
      if interval_value
        errors << "interval must be a positive integer" unless interval_value > 0 
      end
    end
    
    def errors
      @errors ||= []
    end
    
    def valid?
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
