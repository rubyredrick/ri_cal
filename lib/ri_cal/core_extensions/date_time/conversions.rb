#- ©2009 Rick DeNatale
#- All rights reserved

module RiCal
  module CoreExtensions #:nodoc:
    module DateTime #:nodoc:
      module Conversions
        # Return an RiCal::PropertyValue::DateTime representing the receiver
        def to_ri_cal_date_time_value
          RiCal::PropertyValue::DateTime.from_time(self)
        end

        alias_method :to_ri_cal_date_or_date_time_value, :to_ri_cal_date_time_value

        # Return the natural ri_cal_property for this object
        def to_ri_cal_property_value
          to_ri_cal_date_time_value
        end
        
        # Return a proxy to this object which will be interpreted as a floating time.
        def with_floating_timezone
          RiCal::TimeWithFloatingTimezone.new(self)
        end
      end
    end
  end
end