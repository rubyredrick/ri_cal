module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue
      module EnumerationSupportMethods # :nodoc:

        # if the recurrence rule has a bysetpos part we need to search starting with the
        # first time in the frequency period containing the start time specified by DTSTART
        def adjust_start(start_time) # :nodoc:
          if by_list[:bysetpos]
            case freq
            when "SECONDLY"
              start_time
            when "MINUTELY"
              start_time.change(:seconds => 0)
            when "HOURLY"
              start_time.change(
              :minutes => 0, 
              :seconds => start_time.sec
              )
            when "DAILY"
              start_time.change(
              :hour => 0,
              :minutes => start_time.min, 
              :seconds => start_time.sec
              )
            when "WEEKLY"
              start_of_week(time)
            when "MONTHLY"
              start_time.change(
              :day => 1, 
              :hour => start_time.hour, 
              :minutes => start_time.min,
              :seconds => start_time.sec
              )
            when "YEARLY"
              start_time.change(
              :month => 1,
              :day => start_time.day,
              :hour => start_time.hour,
              :minutes => start_time.min,
              :seconds => start_time.sec
              )
            end
          else
            start_time
          end
        end
        
        def enumerator(component) # :nodoc:
          Enumerator.for(self, component, by_list[:bysetpos])
        end

        def exhausted?(count, time) # :nodoc:
          (@count && count > @count) || (@until && (time > @until))
        end

        def in_same_set?(time1, time2) # :nodoc:
          case freq
          when "SECONDLY"
            [time1.year, time1.month, time1.day, time1.hour, time1.min, time1.sec] ==
            [time2.year, time2.month, time2.day, time2.hour, time2.min, time2.sec] 
          when "MINUTELY"
            [time1.year, time1.month, time1.day, time1.hour, time1.min] ==
            [time2.year, time2.month, time2.day, time2.hour, time2.min] 
          when "HOURLY"
            [time1.year, time1.month, time1.day, time1.hour] ==
            [time2.year, time2.month, time2.day, time2.hour] 
          when "DAILY"
            [time1.year, time1.month, time1.day] ==
            [time2.year, time2.month, time2.day] 
          when "WEEKLY"
            sow1 = start_of_week(time1)
            sow2 = start_of_week(time2)
            [sow1.year, sow1.month, sow1.day] ==
            [sow2.year, sow2.month, sow2.day] 
          when "MONTHLY"
            [time1.year, time1.month] ==
            [time2.year, time2.month] 
          when "YEARLY"
            time1.year == time2.year 
          end
        end


        # determine if time should be excluded due to by rules
        def exclude_time_by_rule?(time, enumerator) # :nodoc:
          #TODO - this is overdoing it in cases like by_month with a frequency longer than a month
          time != enumerator.start_time &&( 
          exclude_time_by_value_rule?(:bysecond, time.sec) ||
          exclude_time_by_value_rule?(:byminute, time.min) ||
          exclude_time_by_value_rule?(:byhour, time.hour) ||
          exclude_time_by_value_rule?(:bymonth, time.month) ||
          exclude_time_by_inclusion_rule?(:byday, time) ||
          exclude_time_by_inclusion_rule?(:bymonthday, time) ||
          exclude_time_by_inclusion_rule?(:byyearday, time) ||
          exclude_time_by_inclusion_rule?(:byweekno, time))
        end

        def exclude_time_by_value_rule?(rule_selector, value) # :nodoc:
          valid = by_list[rule_selector]
          valid && !valid.include?(value)
        end

        def exclude_time_by_inclusion_rule?(rule_selector, time) # :nodoc:
          valid = by_list[rule_selector]
          valid && !valid.any? {|rule| rule.include?(time)}
        end

        def by_rule_list(which) # :nodoc:
          if @by_list
            @by_list[which]
          else
            nil
          end
        end
        
        def first_for_byrule(rule_type, time, enumerator, debug = false)
          rules = by_rule_list(rule_type)
          if rules
            list = enumerator.by_rule_list(rule_type, rules, time).first
          end
          nil
        end
        
        def next_for_byrule(rule_type, time, enumerator, debug = false)
          rules = by_rule_list(rule_type)
          if rules
            list = enumerator.by_rule_list(rule_type, rules, time)
            result = list.find {|t| 
              t > time
              }
            return result
          end
          nil
        end

        def first_for_list_rule(rule_name, &find_block)
          items = by_rule_list(rule_name)
          if items
            items.first
          else
            nil
          end
        end

        def next_for_list_rule(rule_name, &find_block)
          items = by_rule_list(rule_name)
          if items
            items.find(&find_block)
          else
            nil
          end
        end
        
        def has_scoped_by_day_rule?(scope)
          by_rule_list(:byday) && @by_day_scope == scope
        end

        def first_for_scoped_byday_rule(scope, time, enumerator)
          if has_scoped_by_day_rule?(scope)
            if scope == :daily
              time
            else
              first_for_byrule(:byday, time, enumerator)
            end
          else
            return nil
          end
        end

        def next_for_scoped_byday_rule(scope, time, enumerator)
          if has_scoped_by_day_rule?(scope)
            if scope == :daily
              time.advance(:days => 1)
            else
              next_for_byrule(:byday, time, enumerator, scope == :weekly)
            end
          else
            return nil
          end
        end

        def next_for_daily_scoped_byday_rule(time)
          new_time = time.advance(:days => 1)
          if freq == "WEEKLY" && interval > 1 && new_time.wday == wkst_day
            return new_time.advance(:weeks => interval - 1)
          elsif freq == "MONTHLY" && interval > 1 && new_time.month != time.month
            return new_time.advance(:months => interval - 1)
          elsif freq == "YEARLY" && interval > 1 && new_time.year != time.year
            return new_time.advance(:years => interval - 1)
          else
            return new_time
          end
        end
      end
    end
  end
end