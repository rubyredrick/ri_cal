module RiCal
  module CoreExtensions
    module DateTime
      module Conversions
        def to_ri_cal_date_time_value
          RiCal::PropertyValue::DateTime.from_time(self)
        end
      end
    end
  end
end