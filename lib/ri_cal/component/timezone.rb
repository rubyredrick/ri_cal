require File.join(File.dirname(__FILE__), %w[.. properties timezone.rb])

module RiCal
  class Component
    # An Timezone (VTIMEZONE) calendar component describes a timezone used within the calendar.
    # A Timezone has two or more TimezonePeriod subcomponents which describe the transitions between
    # standard and daylight saving time.
    #
    # to see the property accessing methods for this class see the RiCal::Properties::Timezone module
    class Timezone < Component
      include RiCal::Properties::Timezone

      def self.entity_name #:nodoc:
        "VTIMEZONE"
      end
      
      def standard #:nodoc:
        @subcomponents["STANDARD"]
      end
      
      def daylight #:nodoc:
        @subcomponents["DAYLIGHT"]
      end
      
      def last_period(standard, daylight) #:nodoc:
        if standard
          if daylight
            standard.dtstart > daylight.dtstart ? standard : daylight
          else
            standard
          end
        else
          daylight
        end
      end
      
      def last_before_utc(period_array, time) #:nodoc:
        candidates = period_array.map {|period| 
          period.last_before_utc(time)
        }
        result = candidates.max {|a, b| a.dtstart_property <=> b.dtstart_property}
        result
      end
      
      def last_before_local(period_array, time) #:nodoc:
        candidates = period_array.map {|period| 
          period.last_before_local(time)
        }
        result = candidates.max {|a, b| a.dtstart_property <=> b.dtstart_property}
        result
      end
      
      # convert time from utc time to this time zone
      def utc_to_local(time)
        time = time.to_ri_cal_date_time_value
        effective_period = last_period(last_before_utc(standard, time), last_before_utc(daylight, time))
        time + effective_period.tzoffsetto_property
      end
      
      # convert time from this time zone to utc time
      def local_to_utc(time)
        time = time.to_ri_cal_date_time_value
        effective_period = last_period(last_before_local(standard, time), last_before_local(daylight, time))
        time - effective_period.tzoffsetto_property
      end
    end
  end
end


%w[timezone_period.rb daylight_period.rb standard_period.rb].each do |filename|  
  require "#{File.dirname(__FILE__)}/timezone/#{filename}"
end