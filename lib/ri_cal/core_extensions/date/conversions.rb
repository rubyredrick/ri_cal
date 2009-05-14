module RiCal
  module CoreExtensions #:nodoc:
    module Date #:nodoc:
      #- ©2009 Rick DeNatale
      #- All rights reserved. Refer to the file README.txt for the license
      #
      module Conversions #:nodoc:
        # Return an RiCal::PropertyValue::DateTime representing the receiver
        def to_ri_cal_date_time_value(timezone_finder = nil)
          RiCal::PropertyValue::DateTime.new(timezone_finder, :value => self)
        end
        
        # Return an RiCal::PropertyValue::Date representing the receiver
        def to_ri_cal_date_value(timezone_finder = nil)
          RiCal::PropertyValue::Date.new(timezone_finder, :value => self)
        end

        alias_method :to_ri_cal_date_or_date_time_value, :to_ri_cal_date_value
        alias_method :to_ri_cal_occurrence_list_value, :to_ri_cal_date_value
        
        # Return the natural ri_cal_property for this object
        def to_ri_cal_property_value(timezone_finder = nil)
          to_ri_cal_date_value(timezone_finder)
        end
      end
    end
  end
end