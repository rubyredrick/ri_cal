require File.join(File.dirname(__FILE__), %w[.. .. properties timezone_period.rb])

module RiCal
  class Component
    class Timezone
      #- ©2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license
      #
      # A TimezonePeriod is a component of a timezone representing a period during which a particular offset from UTC is
      # in effect.
      #
      # to see the property accessing methods for this class see the RiCal::Properties::TimezonePeriod module
      class TimezonePeriod < Component
        include Properties::TimezonePeriod

        include OccurrenceEnumerator

        def zone_identifier #:nodoc:
          tzname.first
        end

        def dtend #:nodoc:
          nil
        end

        def exdate_property #:nodoc:
          nil
        end
        
        def utc_total_offset #:nodoc:
          tzoffsetfrom_property.to_seconds
        end

        def exrule_property #:nodoc:
          nil
        end

        def last_before_utc(utc_time) #:nodoc:
          last_before_local(utc_time + tzoffsetfrom_property)
        end

        def last_before_local(local_time) #:nodoc:
          cand_occurrence = nil
          each do |occurrence|
            return cand_occurrence if occurrence.dtstart_property > local_time
            cand_occurrence = occurrence
          end
          return cand_occurrence
        end
      end
    end
  end
end

