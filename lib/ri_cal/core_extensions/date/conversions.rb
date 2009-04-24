module RiCal
  module CoreExtensions #:nodoc:
    module Date #:nodoc:
      module Conversions
        # Return an RiCal::PropertyValue::DateTime representing the receiver
        def to_ri_cal_date_time_value
          RiCal::PropertyValue::DateTime.new(:value => self)
        end
        
        # Return an RiCal::PropertyValue::Date representing the receiver
        def to_ri_cal_date_value
          RiCal::PropertyValue::Date.new(:value => self)
        end

        alias_method :to_ri_cal_date_or_date_time_value, :to_ri_cal_date_value
        
        # Return the natural ri_cal_property for this object
        def to_ri_cal_property_value
          to_ri_cal_date_value
        end
      end
    end
  end
end