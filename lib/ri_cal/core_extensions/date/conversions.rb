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
        
        def to_overlap_range_start
          to_datetime
        end
        
        def to_overlap_range_end
          to_ri_cal_date_time_value.end_of_day.to_datetime
        end
        
        unless defined? ActiveSupport
          # A method to keep Time, Date and DateTime instances interchangeable on conversions.
          # In this case, it simply returns +self+.
          def to_date
            self
          end if RUBY_VERSION < '1.9'

          # Converts a Date instance to a Time, where the time is set to the beginning of the day.
          # The timezone can be either :local or :utc (default :local).
          #
          # ==== Examples
          #   date = Date.new(2007, 11, 10)  # => Sat, 10 Nov 2007
          #
          #   date.to_time                   # => Sat Nov 10 00:00:00 0800 2007
          #   date.to_time(:local)           # => Sat Nov 10 00:00:00 0800 2007
          #
          #   date.to_time(:utc)             # => Sat Nov 10 00:00:00 UTC 2007
          def to_time(form = :local)
            ::Time.send("#{form}_time", year, month, day)
          end

          # Converts a Date instance to a DateTime, where the time is set to the beginning of the day
          # and UTC offset is set to 0.
          #
          # ==== Examples
          #   date = Date.new(2007, 11, 10)  # => Sat, 10 Nov 2007
          #
          #   date.to_datetime               # => Sat, 10 Nov 2007 00:00:00 0000
          def to_datetime
            ::DateTime.civil(year, month, day, 0, 0, 0, 0)
          end if RUBY_VERSION < '1.9'
        end
      end
    end
  end
end