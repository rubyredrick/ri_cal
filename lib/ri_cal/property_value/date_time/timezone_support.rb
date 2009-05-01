module RiCal
  class PropertyValue
    # Time zone related ethods for DateTime
    module TimezoneSupport
      class TZInfoTimeZoneWrapper

        attr_accessor :tzinfo_timezone, :date_time_prop

        def initialize(tzinfo_timezone, date_time_prop)
          self.tzinfo_timezone, self.date_time_prop = tzinfo_timezone, date_time_prop
        end
        
        def timezone_finder
          date_time_prop.timezone_finder
        end

        def identifier
          tzinfo_timezone.identifier
        end

        def local_to_utc(local)
          DateTime.new(timezone_finder, :tzid => "UTC", :value => tzinfo_timezone.local_to_utc(date_time_prop.to_datetime))
        end

        def period_for_utc(utc_time)
          tzinfo_timezone.period_for_utc(utc_time.to_ri_cal_ruby_value)
        end
      end

      class ActiveSupportTimeZoneWrapper < TZInfoTimeZoneWrapper
        def initialize(active_support_time_zone, date_time_prop)
          super(active_support_time_zone.tzinfo, date_time_prop)
        end
      end
      
      

      class TimezoneID
        attr_reader :identifier, :date_time_prop
        def initialize(identifier, date_time_prop)
           @identifier = identifier
          @date_time_prop = date_time_prop
        end

        def tzinfo_timezone
          nil
        end
        
        def timezone_finder
          date_time_prop.timezone_finder
        end

        def resolved
          @date_time_prop.timezone_finder.find_timezone(identifier)
        end
        
        def local_to_utc(local)
          resolved.local_to_utc(date_time_prop)
        end
      end
      
      # Return the timezone id of the receiver, or nil if it is a floating time
      def tzid
        @tzid
      end

      def tzid=(string)
        @tzid = string
      end

      def timezone
        @timezone ||= TimezoneID.new(tzid, self)
      end
      
      def timezone=(time_zone) #:nodoc:
        @timezone = if time_zone.respond_to?(:tzinfo)
          ActiveSupportTimeZoneWrapper.new(time_zone, self)
        elsif TZInfo::Timezone === time_zone
          TZInfoTimeZoneWrapper.new(time_zone, self)
        elsif time_zone = FloatingTimezone
          time_zone
        else
          TimezoneID.new(time_zone, self)
        end
        self.tzid = @timezone.identifier
      end
      
      # Determine if the receiver has a local time zone, i.e. it is not a floating time or a UTC time
      def has_local_timezone?
        tzid && tzid != "UTC"
      end
      
      def tzinfo_timezone
        timezone && timezone.tzinfo_timezone
      end

      # Return the receiver if it has a floating time zone already,
      # otherwise return a DATETIME property with the same time as the receiver but with a floating time zone
      def with_floating_timezone
        if @time_zone == FloatingTimezone
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

      # Returns the simultaneous time in <tt>Time.zone</tt>, or the specified zone.
      def in_time_zone(new_zone = nil)
        if new_zone.nil?
        end
        return self if time_zone == new_zone
        utc.in_time_zone(new_zone)
      end

      #TODO: implement localtime - How do we know the local timezone in general.
    end
  end
end