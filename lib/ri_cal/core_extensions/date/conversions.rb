module RiCal
  module CoreExtensions
    module Date
      module Conversions
        def to_ri_cal_date_time_value
          RiCal::DateValue.from_date(self)
        end
      end
    end
  end
end