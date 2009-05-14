module RiCal
  module CoreExtensions #:nodoc:
    module String #:nodoc:
      #- ©2009 Rick DeNatale
      #- All rights reserved. Refer to the file README.txt for the license
      #
      module Conversions #:nodoc:
        # Parse the receiver as an RiCal::PropertyValue::DateTime
        def to_ri_cal_date_time_value(timezone_finder = nil)
          params, value = *Parser.params_and_value(self, :no_leading_semicolon)
          if PropertyValue::DateTime.valid_string?(value)
             PropertyValue::DateTime.new(timezone_finder, :params => params, :value => value)
           else
             raise InvalidPropertyValue.new("#{self.inspect} is not a valid rfc 2445 date-time")
           end
        end
        

        def to_ri_cal_date_or_date_time_value(timezone_finder = nil)
          params, value = *Parser.params_and_value(self, :no_leading_semicolon)
          if PropertyValue::DateTime.valid_string?(value) || PropertyValue::Date.valid_string?(value)
            PropertyValue.date_or_date_time(timezone_finder, :params => params, :value => value)
          else
            raise InvalidPropertyValue.new("#{self.inspect} is not a valid rfc 2445 date or date-time")
          end
        end

        # Parse the receiver as an RiCal::PropertyValue::DurationValue
        def to_ri_cal_duration_value(timezone_finder = nil)
          params, value = *Parser.params_and_value(self)
          if PropertyValue::Duration.valid_string?(value)
            PropertyValue::Duration.new(timezone_finder, :params => params, :value => value)
          else
            raise InvalidPropertyValue.new("#{self.inspect} is not a valid rfc 2445 duration")
          end
        end

        def to_ri_cal_occurrence_list_value(timezone_finder = nil)
          params, value = *Parser.params_and_value(self, :no_leading_semicolon)
          if PropertyValue::DateTime.valid_string?(value)
            PropertyValue::DateTime.new(timezone_finder, :params => params, :value => value)
          elsif PropertyValue::Date.valid_string?(value)
            PropertyValue::Date.new(timezone_finder, :params => params, :value => value)
          elsif PropertyValue::Period.valid_string?(value)
            PropertyValue::Period.new(timezone_finder, :params => params, :value => value)
          else
            raise "Invalid value for occurrence list #{self.inspect}"
          end
        end
 
        # code stolen from ActiveSupport Gem
        unless  ::String.instance_methods.include?("camelize")
          # Convert the receiver to camelized form
          # This method duplicates the method provided by ActiveSupport, and will only be defined
          # by the RiCal gem if it is not already defined.
          def camelize
            self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
          end
        end
      end
    end
  end
end