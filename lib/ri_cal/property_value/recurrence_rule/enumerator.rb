module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue
      class Enumerator # :nodoc:
        # base_time gets changed everytime the time is updated by the recurrence rule's frequency
        attr_accessor :start_time, :duration, :next_time, :recurrence_rule, :base_time
        def initialize(recurrence_rule, component, setpos_list)
          self.recurrence_rule = recurrence_rule
          self.start_time = component.default_start_time
          self.duration = component.default_duration
          self.next_time = recurrence_rule.adjust_start(self.start_time)
          self.base_time = next_time
          @bounded = recurrence_rule.bounded?
          @count = 0
          @setpos_list = setpos_list
          @setpos = 1
          @next_occurrence_count = 0
          # @by_rule_list_id = {}
          # @by_rule_list = {}
        end
        
        def self.for(recurrence_rule, component, setpos_list) # :nodoc:
          if !setpos_list || setpos_list.all? {|setpos| setpos > 1}
            self.new(recurrence_rule, component, setpos_list)
          else
            NegativeSetposEnumerator.new(recurrence_rule, start_time, end_time, setpos_list)
          end
        end        
        
        def by_rule_list(rule_type, rules, time)
          new_list_id = rules.first.list_id(time)
          if @by_rule_list_id != new_list_id
            @by_rule_list_id = new_list_id
            @by_rule_list = rules.map {|rule| rule.matches_for(time)}.flatten.sort
          end
          @by_rule_list
        end
        
        def same_week?(date_time)
          rputs "initializing @start_of_week" unless @start_of_week
          @start_of_week ||= date_time.start_of_week_with_wkst(recurrence_rule.wkst_day)
          result = date_time.in_week_starting?(@start_of_week)
          rputs "same_week?: #{result} @start_of_week is #{@start_of_week}, date_time is #{date_time}"
          result
        end
        
        def week_changed?(date)
          !same_week?(date)
        end
        
        def advance_base_time(changes)
          self.base_time = base_time.advance(changes)
        end

        def advance_and_reset(amount, which, resets)
          advance_base_time(which => amount)
          if resets
            self.base_time = base_time.change(resets)
          end
          base_time
        end

        def advance_by_years(amount, resets = nil)
          advance_and_reset(amount, :years, resets)
        end
        
        def advance_by_months(amount, resets = nil)
          advance_and_reset(amount, :months, resets)
        end

        def advance_by_days(amount, resets = nil)
          advance_and_reset(amount, :days, resets)
        end
        
        def advance_by_hours(amount, resets = nil)
          advance_and_reset(amount, :hours, resets)
        end

        def advance_by_minutes(amount, resets = nil)
          advance_and_reset(amount, :minutes, resets)
        end        

        def advance_by_seconds(amount)
          advance_base_time(:seconds => amount)
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
