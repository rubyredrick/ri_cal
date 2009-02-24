module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue

      # Instances of RecurringDay are used to represent values in BYDAY recurrence rule parts
      #
      class RecurringDay 

        DayNames = %w{SU MO TU WE TH FR SA} unless defined? DayNames
        day_nums = {}
        unless defined? DayNums
          DayNames.each_with_index { |name, i| day_nums[name] = i }
          DayNums = day_nums
        end

        attr_reader :source
        def initialize(source, rrule)
          @source = source
          @rrule = rrule
          wd_match = source.match(/([+-]?\d*)(SU|MO|TU|WE|TH|FR|SA)/)
          if wd_match
            @day, @ordinal = wd_match[2], wd_match[1]
          end
        end

        def valid?
          !@day.nil?
        end

        def ==(another)
          self.class === another && to_a = another.to_a
        end

        def to_a
          [@day, @ordinal]
        end

        def to_s
          "#{@ordinal}#{@day}"
        end

        def ordinal_match(date_or_time)
          if @ordinal == ""
            true
          else
            n = @ordinal.to_i
            if @rrule.freq == "YEARLY"
              date_or_time.nth_wday_in_year?(n, DayNums[@day]) 
            else
              date_or_time.nth_wday_in_month?(n, DayNums[@day])
            end
          end
        end

        # Determine if a particular date, time, or date_time is included in the recurrence
        def include?(date_or_time)
          date_or_time.wday == DayNums[@day] && ordinal_match(date_or_time)
        end
      end
    end
  end
end