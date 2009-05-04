module RiCal
  class PropertyValue
    #- ©2009 Rick DeNatale
    #- All rights reserved. Refer to the file README.txt for the license
    #
    # Time zone related ethods for DateTime
    module TimezoneSupport      
      # Return the timezone id of the receiver, or nil if it is a floating time
      def tzid
        @tzid
      end

      def tzid=(string)
        @tzid = string
        @timezone = nil
      end

      def timezone
        @timezone ||= timezone_finder.find_timezone(@tzid)
      end
      
      # Determine if the receiver has a local time zone, i.e. it is not a floating time or a UTC time
      def has_local_timezone?
        tzid && tzid != "UTC"
      end
      
      # Return the receiver if it has a floating time zone already,
      # otherwise return a DATETIME property with the same time as the receiver but with a floating time zone
      def with_floating_timezone
        if @tzid == nil
          self
        else
          @date_time_value.with_floating_timezone.to_ri_cal_date_time_value
        end
      end

      # Returns a instance that represents the time in UTC.
      def utc
        if has_local_timezone?
          timezone.local_to_utc(self)
        else  # Already local or a floating time
          self
        end
      end
      
      def utc?
        tzid == "UTC"
      end

      # Returns the simultaneous time in the specified zone.
      def in_time_zone(new_zone)
        new_zone = timezone_finder.find_timezone(new_zone)
        return self if tzid == new_zone.identifier
        if has_local_timezone?
          new_zone.utc_to_local(utc)
        elsif utc?
          new_zone.utc_to_local(self)
        else # Floating time
          DateTime.new(timezone_finder, :value => @date_time_value, :tzid => new_zone.identifier)
        end
      end
    end
  end
end