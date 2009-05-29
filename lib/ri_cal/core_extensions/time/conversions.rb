module RiCal
  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      #- ©2009 Rick DeNatale
      #- All rights reserved. Refer to the file README.txt for the license
      #
      module Conversions
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
        
        # Return a copy of this object which will be interpreted as a floating time.
        def with_floating_timezone
          dup.set_tzid(:floating)
        end
        
        unless defined? ActiveSupport
          # Converts a Time object to a Date, dropping hour, minute, and second precision.
          #
          #   my_time = Time.now  # => Mon Nov 12 22:59:51 -0500 2007
          #   my_time.to_date     # => Mon, 12 Nov 2007
          #
          #   your_time = Time.parse("1/13/2009 1:13:03 P.M.")  # => Tue Jan 13 13:13:03 -0500 2009
          #   your_time.to_date                                 # => Tue, 13 Jan 2009
          def to_date
            ::Date.new(year, month, day)
          end

          # A method to keep Time, Date and DateTime instances interchangeable on conversions.
          # In this case, it simply returns +self+.
          def to_time
            self
          end

          # Converts a Time instance to a Ruby DateTime instance, preserving UTC offset.
          #
          #   my_time = Time.now    # => Mon Nov 12 23:04:21 -0500 2007
          #   my_time.to_datetime   # => Mon, 12 Nov 2007 23:04:21 -0500
          #
          #   your_time = Time.parse("1/13/2009 1:13:03 P.M.")  # => Tue Jan 13 13:13:03 -0500 2009
          #   your_time.to_datetime                             # => Tue, 13 Jan 2009 13:13:03 -0500
          def to_datetime
            # 86400 is the number of seconds in a day
            ::DateTime.civil(year, month, day, hour, min, sec, RiCal.RationalOffset[utc_offset])
          end
        end
      end
    end
  end
end