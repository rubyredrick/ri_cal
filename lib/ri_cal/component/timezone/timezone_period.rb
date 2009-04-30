require File.join(File.dirname(__FILE__), %w[.. .. properties timezone_period.rb])

module RiCal
  class Component
    class Timezone
      # A TimezonePeriod is a component of a timezone representing a period during which a particular offset from UTC is
      # in effect.
      #
      # to see the property accessing methods for this class see the RiCal::Properties::TimezonePeriod module
      class TimezonePeriod < Component
        include Properties::TimezonePeriod

        include OccurrenceEnumerator

        def zone_identifier
          tzname.first
        end

        def dtend #:nodoc:
          nil
        end

        def exdate_property #:nodoc:
          nil
        end
        
        def utc_total_offset
          tzoffsetfrom_property.to_seconds
        end

        def exrule_property #:nodoc:
          nil
        end

        def last_before_utc(utc_time) #:nodoc:
          last_before_local(utc_time + tzoffsetfrom_property)
        end

        def last_before_local(local_time) #:nodoc:
          around_local(local_time).first
        end
        
        # return an array of the  the last occurence which starts before the time,
        # and the occurrence after that.
        def around_local(local_time) #:nodoc:
          cand_occurrence = nil
          each do |occurrence|
            if occurrence.dtstart_property > local_time
              return [cand_occurrence, occurrence]
            else
              cand_occurrence = occurrence
            end
          end
          return [cand_occurrence, nil]
        end
      end
    end
  end
end
