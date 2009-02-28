require 'date'
module RiCal
  class PropertyValue
    # RiCal::PropertyValue::CalAddress represents an icalendar Date property value
    # which is defined in 
    # RFC 2445 section 4.3.4 p 34
    class Date < PropertyValue
      # Returns the value of the reciever as an RFC 2445 iCalendar string
      def value
        if @date_time_value
          @date_time_value.strftime("%Y%m%d")
        else
          nil
        end
      end 

      def value=(val) # :nodoc:
        case val
        when nil
          @date_time_value = nil
        when String
          @date_time_value = ::DateTime.parse(val)
        when ::Time, ::Date, ::DateTime
          @date_time_value = ::DateTime.parse(val.strftime("%Y%m%d"))
        end
      end
      
      def year
        @date_time_value.year
      end
      
      def month
        @date_time_value.month
      end
      
      def day
        @date_time_value.day
      end
      
      def year
        @date_time_value.year
      end
      
      def month
        @date_time_value.month
      end
      
      def day
        @date_time_value.day
      end

      # Used by RiCal specs - returns a Ruby Date
      def to_ri_cal_ruby_value
        ::Date.parse(@date_time_value.strftime("%Y%m%d"))
      end

      # Return an RiCal::PropertyValue::DateTime representing the receiver
      def to_ri_cal_date_time_value
        PropertyValue::DateTime.new(:value => @date_time_value)
      end    

      # Return an RiCal::PropertyValue::Date representing the receiver
      def to_ri_cal_date_value
        self
      end
      
      def compute_change(d, options) # :nodoc:
        ::Date.civil((options[:year] || d.year), (options[:month] || d.month), (options[:day] || d.day))
      end

      def compute_advance(d, options) # :nodoc:
        d = d >> options[:years] * 12 if options[:years]
        d = d >> options[:months]     if options[:months]
        d = d +  options[:weeks] * 7  if options[:weeks]
        d = d +  options[:days]       if options[:days]
        compute_change(@date_time_value, :year => d.year, :month => d.month, :day => d.day)
      end

      def advance(options) # :nodoc:
        PropertyValue::Date.new(:value => compute_advance(@date_time_value, options), :params =>(params ? params.dup : nil) )
      end

      def change(options) # :nodoc:
        PropertyValue::Date.new(:value => compute_change(@date_time_value, options), :params => (params ? params.dup : nil) )
      end

      # Delegate unknown messages to the wrappered Date instance.
      # TODO: Is this really necessary?
      def method_missing(selector, *args)
        @date_value.send(selector, *args)
      end
      
      # TODO: consider if this should be a period rather than a hash
      def occurrence_hash(default_duration) # :nodoc:
        date_time = self.to_ri_cal_date_time_value
        {:start => date_time, 
          :end => date_time.advance(:hours => 24, :seconds => -1)}
        end
      end
    end
  end