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
        
        def dtend #:nodoc:
          nil
        end
        
        def exdate_property #:nodoc:
          nil
        end
        
        def exrule_property #:nodoc:
          nil
        end
        
        def last_before_utc(utc_time) #:nodoc:
          last_before_local(utc_time + tzoffsetfrom_property)
        end
        
        def last_before_local(local_time) #:nodoc:
          result = nil
          each do |occurrence|
            return result if occurrence.dtstart_property >= local_time
            result = occurrence
          end
          return result
        end
      end
    end
  end
end
