module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue

      # Instances of RecurringDay are used to represent values in BYDAY recurrence rule parts
      #
      class RecurringDay # :nodoc: 

        DayNames = %w{SU MO TU WE TH FR SA} unless defined? DayNames
        day_nums = {}
        unless defined? DayNums
          DayNames.each_with_index { |name, i| day_nums[name] = i }
          DayNums = day_nums
        end

        attr_reader :source, :scope
        def initialize(source, rrule, scope = "MONTHLY")
          @source = source
          @rrule = rrule
          @scope = scope
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
        
        # return a list id for a given time to allow the enumerator to cache lists
        def list_id(time)
          if @scope == "YEARLY"
            time.year
          else
            (time.year * 100) + time.month
          end
        end
 
        # return a list of times which match the time parameter within the scope of the RecurringDay
        def matches_for(time)
          case @scope
          when :yearly
            yearly_matches_for(time)
          when :monthly
            monthly_matches_for(time)
          else
            walkback = caller.grep(/recurrence/i)
            raise "Logic error! \n  #{walkback.join("\n  ")}"
          end         
        end
        
        def yearly_matches_for(time)
          if @ordinal == ""
            t = time.nth_wday_in_year(1, DayNums[@day])
            result = []
            year = time.year
            while t.year == year
              result << t
              t = t.advance(:week => 1)
            end
            result
          else
            [time.nth_wday_in_year(@ordinal.to_i, DayNums[@day])]
          end
        end
        
        def monthly_matches_for(time)
          if @ordinal == ""
            t = time.nth_wday_in_month(1, DayNums[@day])
            result = []
            month = time.month
            while t.month == month
              result << t
              t = t.advance(:week => 1)
            end
            result
          else
            [time.nth_wday_in_year(@ordinal.to_i, DayNums[@day])]
          end
        end

        def to_s
          "#{@ordinal}#{@day}"
        end
        
        # return a list id for a given time to allow the enumerator to cache lists
        def list_id(time)
          if @scope == "YEARLY"
            time.year
          else
            (time.year * 100) + time.month
          end
        end
 
        # return a list of times which match the time parameter within the scope of the RecurringDay
        def matches_for(time)
          case @scope
          when :yearly
            yearly_matches_for(time)
          when :monthly
            monthly_matches_for(time)
          else
            walkback = caller.grep(/recurrence/i)
            raise "Logic error! \n  #{walkback.join("\n  ")}"
          end         
        end
        
        def yearly_matches_for(time)
          if @ordinal == ""
            t = time.nth_wday_in_year(1, DayNums[@day])
            result = []
            year = time.year
            while t.year == year
              result << t
              t = t.advance(:week => 1)
            end
            result
          else
            [time.nth_wday_in_year(@ordinal.to_i, DayNums[@day])]
          end
        end
        
        def monthly_matches_for(time)
          if @ordinal == ""
            t = time.nth_wday_in_month(1, DayNums[@day])
            result = []
            month = time.month
            while t.month == month
              result << t
              t = t.advance(:week => 1)
            end
            result
          else
            [time.nth_wday_in_year(@ordinal.to_i, DayNums[@day])]
          end
        end

        def ordinal_match(date_or_time)
          if @ordinal == ""
            true
          else
            n = @ordinal.to_i
            if @scope == "YEARLY"
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