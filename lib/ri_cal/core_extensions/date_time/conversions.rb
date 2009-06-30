require 'date'
module RiCal
  module CoreExtensions #:nodoc:
    module DateTime #:nodoc:
      #- ©2009 Rick DeNatale
      #- All rights reserved. Refer to the file README.txt for the license
      #
      module Conversions #:nodoc:
        # Return an RiCal::PropertyValue::DateTime representing the receiver
        def to_ri_cal_date_time_value(timezone_finder = nil) #:nodoc:
          RiCal::PropertyValue::DateTime.new(
               timezone_finder, 
               :value => strftime("%Y%m%dT%H%M%S"), 
               :params => {"TZID" => self.tzid || :default})
        end

        alias_method :to_ri_cal_date_or_date_time_value, :to_ri_cal_date_time_value #:nodoc:
        alias_method :to_ri_cal_occurrence_list_value, :to_ri_cal_date_time_value #:nodoc:

        # Return the natural ri_cal_property for this object
        def to_ri_cal_property_value(timezone_finder = nil) #:nodoc:
          to_ri_cal_date_time_value(timezone_finder)
        end
        
        def to_overlap_range_start
          self
        end
        alias_method :to_overlap_range_end, :to_overlap_range_start
        
        # Return a copy of this object which will be interpreted as a floating time.
        def with_floating_timezone
          dup.set_tzid(:floating)
        end
        
        unless defined? ActiveSupport
          # Converts self to a Ruby Date object; time portion is discarded
          def to_date
            ::Date.new(year, month, day)
          end

          # Attempts to convert self to a Ruby Time object; returns self if out of range of Ruby Time class
          # If self has an offset other than 0, self will just be returned unaltered, since there's no clean way to map it to a Time
          def to_time
            self.offset == 0 ? ::Time.utc_time(year, month, day, hour, min, sec) : self
          end

          # To be able to keep Times, Dates and DateTimes interchangeable on conversions
          def to_datetime
            self
          end
        end
      end
    end
  end
end