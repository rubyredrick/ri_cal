module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue
      # Instances of RecurringMonthDay represent BYMONTHDAY parts in recurrence rules
      class RecurringMonthDay < NumberedSpan # :nodoc:

        def last
          31
        end
        
        # return a list id for a given time to allow the enumerator to cache lists
        def list_id(time)
          time.month
        end

        def start_of_next_scope_for(time)
          time.advance(:months => 1).change(:day => @source)
        end
 
        # return a list of times which match the time parameter within the scope of the RecurringDay
        def matches_for(time)
          [time.change(:day => 1).advance(:days => target_for(time)- 1)]
        end
        
        # return a list id for a given time to allow the enumerator to cache lists
        def list_id(time)
          time.month
        end
 
        # return a list of times which match the time parameter within the scope of the RecurringDay
        def matches_for(time)
          [time.change(:day => 1).advance(:days => target_for(time)- 1)]
        end

        def target_for(date_or_time)
          if @source > 0
            @source
          else
            date_or_time.days_in_month + @source + 1
          end
        end

        def include?(date_or_time)
          date_or_time.mday == target_for(date_or_time)
        end
      end
    end
  end
end