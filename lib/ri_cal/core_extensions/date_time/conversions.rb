module RiCal
  module CoreExtensions
    module DateTime
      module Conversions
        # Return an RiCal::PropertyValue::DateTime representing the receiver
        def to_ri_cal_date_time_value
          RiCal::PropertyValue::DateTime.from_time(self)
        end

        alias_method :to_ri_cal_date_or_date_time_value, :to_ri_cal_date_time_value

        def to_ri_cal_property_value
          to_ri_cal_date_time_value
        end
        
        def with_floating_timezone
          RiCal::TimeWithFloatingTimezone.new(self)
        end
      end
    end
  end
end