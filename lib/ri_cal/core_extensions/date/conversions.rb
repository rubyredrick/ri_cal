module RiCal
  module CoreExtensions
    module Date
      module Conversions
        def to_ri_cal_date_time_value
          RiCal::PropertyValue::Date.from_date(self)
        end
      end
    end
  end
end