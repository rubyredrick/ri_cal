require 'date'
module RiCal
  class PropertyValue
    # rfc 2445 section 4.3.4 p 34
    class Date < PropertyValue
      def value
        if @date_time_value
          @date_time_value.strftime("%Y%m%d")
        else
          nil
        end
      end 

      def value=(val)
        case val
        when nil
          @date_time_value = nil
        when String
          @date_time_value = ::DateTime.parse(val)
        when ::Time, ::Date, ::DateTime
          @date_time_value = ::DateTime.parse(val.strftime("%Y%m%d"))
        end
      end

      def ruby_value
        ::Date.parse(@date_time_value.strftime("%Y%m%d"))
      end

      def to_ri_cal_date_time_value
        PropertyValue::DateTime.new(:value => @date_time_value)
      end    

      def to_ri_cal_date_value
        self
      end

      # TODO: consider if this should be a period rather than a hash
      def occurrence_hash(default_duration)
        date_time = self.to_ri_cal_date_time_value
        {:start => date_time, 
          :end => date_time.advance(:hours => 24, :seconds => -1)}
        end
      end
    end
  end