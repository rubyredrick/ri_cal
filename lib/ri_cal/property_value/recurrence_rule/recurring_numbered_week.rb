module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue
      class RecurringNumberedWeek < NumberedSpan # :nodoc:
        def last
          53
        end

        def include?(date_or_time, wkst=1)
          date_or_time.iso_week_num(wkst) == @source
        end
      end
    end
  end
end