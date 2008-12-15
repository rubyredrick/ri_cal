module RiCal
  class RecurrenceRule
    
    attr_reader :count, :until
    def initialize(value_hash)
      self.freq = value_hash[:freq]
      @count= value_hash[:count]
      @until= value_hash[:until]
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
    
    def errors
      @errors ||= []
    end
    
    def valid?
      errors.empty?
    end
  end
end
