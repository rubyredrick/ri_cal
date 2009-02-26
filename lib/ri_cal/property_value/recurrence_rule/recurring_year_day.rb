module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue
      class RecurringYearDay < NumberedSpan # :nodoc:

        def last
          366
        end

        def leap_year?(year)
          year % 4 == 0 && (year % 400 == 0 || year % 100 != 0)
        end 


        def length_of_year(year)
          leap_year?(year) ? 366 : 365
        end 

        def include?(date_or_time)
          if @source > 0
            target = @source
          else
            target = length_of_year(date_or_time.year) + @source + 1
          end
          date_or_time.yday == target
        end
      end
    end
  end
end