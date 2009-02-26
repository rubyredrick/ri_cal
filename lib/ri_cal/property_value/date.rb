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

      # TODO: consider if this should be a period rather than a hash
      def occurrence_hash(default_duration) # :nodoc:
        date_time = self.to_ri_cal_date_time_value
        {:start => date_time, 
          :end => date_time.advance(:hours => 24, :seconds => -1)}
        end
      end
    end
  end