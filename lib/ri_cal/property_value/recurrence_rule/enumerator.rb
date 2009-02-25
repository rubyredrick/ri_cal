module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue
      class Enumerator
        attr_accessor :start_time, :duration, :next_time, :recurrence_rule
        attr_reader :reset_second, :reset_minute, :reset_hour, :reset_day, :reset_month
        def initialize(recurrence_rule, component, setpos_list)
          self.recurrence_rule = recurrence_rule
          self.start_time = component.default_start_time
          self.duration = component.default_duration
          self.next_time = recurrence_rule.adjust_start(self.start_time)
          @bounded = recurrence_rule.bounded?
          @count = 0
          @setpos_list = setpos_list
          @setpos = 1
          @reset_second = recurrence_rule.reset_second || start_time.sec
          @reset_minute = recurrence_rule.reset_minute || start_time.min
          @reset_hour = recurrence_rule.reset_hour || start_time.hour
          @reset_day = recurrence_rule.reset_day || start_time.day
          @reset_month = recurrence_rule.reset_month || start_time.month
          @next_occurrence_count = 0
        end
        
        def bounded?
          @bounded
        end

        def result_hash(date_time_value)
          {:start => date_time_value, :end => nil}
        end

        def result_passes_setpos_filter?(result)
          result_setpos = @setpos
          if recurrence_rule.in_same_set?(result, next_time)
            @setpos += 1
          else
            @setpos = 1
          end
          if (result == start_time) || (result > start_time && @setpos_list.include?(result_setpos))
            return true
          else
            return false
          end
        end

        def result_passes_filters?(result)
          if @setpos_list
            result_passes_setpos_filter?(result)
          else 
            result >= start_time
          end
        end

        def next_occurrence
          while true
            @next_occurrence_count += 1
            result = next_time
            self.next_time = recurrence_rule.advance(result, self)
            if result_passes_filters?(result)
              @count += 1              
              return recurrence_rule.exhausted?(@count, result) ? nil : result_hash(result)
            end
          end
        end
      end
    end
  end
end
