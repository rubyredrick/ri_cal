module RiCal
  module CoreExtensions
    module Date
      module Conversions
        # Return an RiCal::PropertyValue::DateTime representing the receiver
        def to_ri_cal_date_time_value
          RiCal::PropertyValue::DateTime.new(:value => self)
        end
        
        def to_ri_cal_date_value
          RiCal::PropertyValue::Date.new(:value => self)
        end
        
        def to_ri_cal_property_value
          to_ri_cal_date_value
        end
      end
    end
  end
end