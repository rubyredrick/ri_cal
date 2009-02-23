module RiCal
  module CoreExtensions
    module String
      module Conversions
        def to_ri_cal_date_time_value
          RiCal::PropertyValue::DateTime.from_string(self)
        end

        def to_ri_cal_duration_value
          RiCal::PropertyValue::Duration.from_string(self)
        end

        # code stolen from ActiveSupport Gem
        unless  ::String.instance_methods.include?("camelize")
          def camelize
            self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
          end
        end
      end
    end
  end
end