module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue
      # Instances of RecurringMonthDay represent BYMONTHDAY parts in recurrence rules
      class RecurringMonthDay < NumberedSpan

        def last
          31
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