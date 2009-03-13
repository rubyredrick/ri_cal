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

        def advance(time, enumerator) # :nodoc:
          time = advance_seconds(time, enumerator)     
          while exclude_time_by_rule?(time, enumerator) && (!@until || (time <= @until))
            time = advance_seconds(time, enumerator)
          end
          time
        end
        
        def advance_seconds(time, enumerator) # :nodoc:
          if freq == 'SECONDLY'
            time_at_change(time, enumerator.advance_by_seconds(interval), enumerator)
          elsif (next_second = next_for_list_rule(:bysecond) {|sec| sec > time.sec})
            time.change_sec(next_second)
          else
            advance_minutes(time, enumerator)
          end
        end
        
        def advance_minutes(time, enumerator) # :nodoc:
          if freq == 'MINUTELY'
            time_at_change(time, enumerator.advance_by_minutes(interval, @minutely_resets), enumerator)
          elsif (next_minute = next_for_list_rule(:byminute) {|min| min > time.min})
            time.change_min(next_minute)
          else
            advance_hours(time, enumerator)
          end
        end

        def advance_hours(time, enumerator, debug=false) # :nodoc:
          if freq == 'HOURLY'
            time_at_change(time, enumerator.advance_by_hours(interval, @hourly_resets), enumerator)
          elsif (next_hour = next_for_list_rule(:byhour) {|hr| hr > time.hour})
            time.change_hour(next_hour)
          else
            advance_days(time, enumerator)
          end
        end
        
        def fast_forward_days(time, enumerator)
          probe = time.advance(:days => interval)
          unless probe.in_same_month_as?(time)
            rputs "***********"
            if (valid_months = by_rule_list(:bymonth)) && !valid_months.empty?
              rputs "valid months are #{valid_months.inspect}"
              probe = probe.advance(:days => interval) until valid_months.include?(probe.month)
              return enumerator.base_time = debug_comment(probe, "fast_forwarded to $ because of bymonth rule")
            end 
          end
          nil
        end
        
        def advance_days(time, enumerator, debug = false) # :nodoc:
          rputs "advance_days(#{time})"
          if freq == 'DAILY'
            if (new_time = fast_forward_days(time, enumerator))
              debug_comment new_time, "returning fast_forward $"
            else
              time_at_change(time, enumerator.advance_by_days(interval, @daily_resets), enumerator)
            end
          elsif (new_time = 
                              (debug_comment next_for_scoped_byday_rule(:daily, time, enumerator), "next for byday:daily is $$" )||
                              (debug_comment next_for_byrule(:bymonthday, time, enumerator), "next for bymonthday is $$")  ||
                              (debug_comment next_for_byrule(:byyearday, time, enumerator), "next for byyearday is $$") 
            )
            debug_comment time_at_change(time, new_time, enumerator), "returning $ from rules"
          else
            advance_weeks(time, enumerator)
          end
        end
        
        def next_time_from_weekly_byday_rule(time, enumerator)
          new_time = next_for_scoped_byday_rule(:weekly, time, enumerator)
          if new_time && (interval == 1 || enumerator.same_week?(new_time))
            new_time
          else
            nil
          end
        end
        
        def advance_weeks(time, enumerator) # :nodoc:
          rputs "advance_weeks(#{time})"
          if freq == 'WEEKLY'
            if (new_time = next_time_from_weekly_byday_rule(time, enumerator))
              debug_comment new_time, "returning $ from advance_weeks due to weekly byday"
            else
              time_at_week_change(time, enumerator.advance_by_days(7 * interval, @daily_resets), enumerator)
            end
          elsif (new_time = next_for_byrule(:byweekno, time, enumerator))
            debug_comment time_at_change(time, new_time, enumerator), "returning $ from advance_weeks due to byweekno"
          elsif (new_time = next_for_scoped_byday_rule(:monthly, time, enumerator))
            debug_comment time_at_change(time, new_time, enumerator), "returning $ for #{time} from advance_weeks due to byday"
          elsif (new_time = next_for_byrule(:bymonthday, time, enumerator))
            debug_comment time_at_change(time, new_time, enumerator), "returning $ for #{time} from advance_weeks due to bymonthday"
          else
            advance_months(time, enumerator)
          end
        end

        def advance_months(time, enumerator) # :nodoc:
          if freq == 'MONTHLY'
            rputs "advancing #{interval} month"
            time_at_month_change(time, enumerator.advance_by_months(interval, @monthly_resets), enumerator)
          elsif (new_month = next_for_list_rule(:bymonth) {|month| month > time.month})
            rputs "cnanging month to #{new_month} in advance_months due to bymonth rule"
            result = time_at_month_change(time, time.change(:month => new_month), enumerator)
            rputs "  returning #{result}"
            result
          else
            advance_years(time, enumerator) # :nodoc:
          end
        end
        
        
        class TimeCollector
          def initialize(first = nil)
            @contents = []
            self << first
          end
          
          def <<(candidate)
            @contents << candidate if candidate
          end
          
          def first
            @contents.compact.sort.first
          end
          
          def to_s
            "[#{@contents.map {|c| c.to_s}.join(", ")}]"
          end
        end
        
        def debug_comment(value, why)          
          rputs why.sub("$", value ? value.to_s : value.inspect)
          value
        end
        
        
        def time_at_change(old_time, new_time, enumerator)
          rputs "time_at_change(#{old_time}, #{new_time})"
          if old_time.year != new_time.year
            debug_comment time_at_year_change(old_time, new_time, enumerator), "returning $ because year changed"
          elsif old_time.month != new_time.month
            debug_comment time_at_month_change(old_time, new_time, enumerator), "returning $ because month changed"
          elsif enumerator.week_changed?(new_time)
            debug_comment time_at_week_change(old_time, new_time, enumerator), "returning $ because week changed"
          else
            debug_comment new_time, "returning $ because nothing changed"
          end
        end
        
        def first_from_bymonth
          @first_from_bymonth ||= (by_rule_list(:bymonth) || []).first
        end
        
        def time_at_year_change(old_time, new_time, enumerator)
          if @yearly_resets
            candidates = TimeCollector.new()
            first_of_year = new_time.change(:month => 1, :day => 1)
            first_month_time =  first_of_year.change(:month => first_from_bymonth) if first_from_bymonth
            base_time = (first_month_time || first_of_year)
            [:daily, :yearly, :monthly].each do |scope| 
              candidates << first_for_scoped_byday_rule(scope, base_time, enumerator)
            end
            candidates << first_for_byrule(:bymonthday, base_time, enumerator)
            first_by_yearday = first_for_byrule(:byyearday, base_time, enumerator)
            first_by_year_day = first_for_byrule(:byyearday, base_time, enumerator)
            rputs "first_by_year_day is #{first_by_year_day}"
            candidates << first_by_year_day
            candidates << first_for_byrule(:byweekno, base_time, enumerator)
            rputs "candidates are #{candidates}"
            first_time = candidates.first || base_time
            rputs "returning #{first_time}"
            time_at_change(new_time, first_time, enumerator)
          else
            new_time
          end         
        end

        def time_at_month_change(old_time, new_time, enumerator)
          rputs "time_at_month_change(#{old_time}, #{new_time})"
          if @monthly_resets
            candidates = TimeCollector.new()
            first_of_month = new_time.change(:day => 1)
            [:daily, :monthly].each do |scope| 
              candidates << first_for_scoped_byday_rule(scope, first_of_month, enumerator)
            end
            candidates << first_for_byrule(:bymonthday, new_time, enumerator)
            rputs "candidates are #{candidates}"
            first_time = candidates.first || new_time
            rputs "returning #{first_time}"
            time_at_change(new_time, first_time, enumerator)
          else
            new_time
          end         
        end

        def time_at_week_change(old_time, new_time, enumerator)
          rputs "time_at_week_change(#{old_time}, #{new_time})"
          if (first_in_week = first_for_scoped_byday_rule(:weekly, new_time.at_start_of_week_with_wkst(wkst_day), enumerator))
            debug_comment time_at_change(new_time, first_in_week), "returning first_in_week = $ "
         else
           debug_comment new_time, "returning new_time = $"
          end         
        end

        def advance_years(time, enumerator) # :nodoc:
          if freq == 'YEARLY'
            time_at_year_change(time, enumerator.advance_by_years(interval, @yearly_resets), enumerator)
            
          elsif(new_time = next_for_scoped_byday_rule(:yearly, time, enumerator))
            returning " #{new_time} from advance_years due to yearly day rule?"
            new_time
          else
            raise Error.new("Logic error or invalid frequency #{freq}")
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
            rputs "list for #{time} is #{list.map {|e| e.to_s}.inspect}" if debug
            result = list.find {|t| 
              t > time
              }
              rputs " result for #{time} is #{result}" if debug
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