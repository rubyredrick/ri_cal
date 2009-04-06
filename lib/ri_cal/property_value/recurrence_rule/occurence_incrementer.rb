module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue
      module RangePredicates
        def same_year?(old_date_time, new_date_time)
          old_date_time.year == new_date_time.year
        end

        def same_month?(old_date_time, new_date_time)
          (old_date_time.month == new_date_time.month) && same_year?(old_date_time, new_date_time)
        end

        def same_day?(old_date_time, new_date_time)
          (old_date_time.day == new_date_time.day) && same_month?(old_date_time, new_date_time)
        end

        def same_hour?(old_date_time, new_date_time)
          (old_date_time.hour == new_date_time.hour) && same_day?(old_date_time, new_date_time)
        end

        def same_minute?(old_date_time, new_date_time)
          (old_date_time.minute == new_date_time.minute) && same_hour?(old_date_time, new_date_time)
        end

        def same_second?(old_date_time, new_date_time)
          (old_date_time.second == new_date_time.second) && same_minute?(old_date_time, new_date_time)
        end
      end

      module TimeManipulation

        def advance_hour(date_time)
          date_time.advance(:hours => 1)
        end

        def top_of_hour(date_time)
          date_time.change(:minute => 0)
        end

        def advance_day(date_time)
          date_time.advance(:days => 1)
        end

        def first_hour_of_day(date_time)
          date_time.change(:hour => 0)
        end

        def advance_week(date_time)
          date_time.advance(:days => 7)
        end

        def first_day_of_week(wkst_day, date_time)
          date_time.at_start_of_week_with_wkst(wkst_day)
        end

        def advance_month(date_time)
          date_time.advance(:months => 1)
        end

        def first_day_of_month(date_time)
          date_time.change(:day => 1)
        end

        def advance_year(date_time)
          date_time.advance(:years => 1)
        end

        def first_day_of_year(date_time)
          date_time.change(:month => 1, :day => 1)
        end

        def first_month_of_year(date_time)
          date_time.change(:month => 1)
        end
      end

      class OccurrenceIncrementer # :nodoc:

        attr_accessor :parent_incrementer, :range_start_time
        attr_reader :leaf_iterator
        
        include RangePredicates
        include TimeManipulation

        def initialize(rrule, parent_iterator)
          self.parent_incrementer = parent_iterator || OccurrenceIncrementer
          self.leaf_iterator = self
        end
        
        def to_s
          "#{self.class.name.sub("RiCal::PropertyValue::RecurrenceRule::", "")}->#{parent_incrementer.to_s.sub("RiCal::PropertyValue::RecurrenceRule::", "")}"
        end

        def next(date_time)
          my_next = increment(date_time)
          self.range_start_time ||= my_next
          parent_incrementer.proposal_from_child(my_next)
        end
        
        def self.proposal_from_child(date_time)
          date_time
        end
        
        def proposal_from_child(date_time)
          
          rputs "#{self.class}.proposal_from_child(#{date_time})"
          if time_in_current_range?(date_time)
            rputs "in current range"
            parent_incrementer.proposal_from_child(date_time)
          else
            rputs "outside of current range, starting new range"
            leaf_iterator.start_new_range(increment(date_time))
          end
        end
        
        def start_new_range(date_time)
          parent_incrementer.start_new_range(date_time)
        end

        # The class acts as the ultimate parent, all times are within it's current range
        def self.time_in_current_range?(date_time)
          true
        end
        
        def self.start_new_range(date_time)
          date_time
        end
        
        def time_in_current_range?(date_time)
          self.range_start_time ||= date_time
          same_range?(range_start_time, date_time)
        end       
        
        def root_iterator?
          parent_incrementer == OccurrenceIncrementer
        end
        
        def leaf_iterator=(value)
          @leaf_iterator = value
          parent_incrementer.leaf_iterator = value
        end
        
        def self.leaf_iterator=(value)
          value
        end

        def by_day_occurrences_for(old_date_time, byday_list)
          parent_incrementer.by_day_occurrences_for(old_date_time, byday_list)
        end        
        
        def contains_daily_incrementer?
          @contains_daily_incrementer ||= leaf_iterator.any_until?(self) {|iterator| iterator.daily_incrementer?}
        end
        
        def self.any_until?(incrementer)
          false
        end
        
        def any_until?(incrementer)
          if self == incrementer
            false
          else
            i_am_it = yield self
            i_am_it  || parent_incrementer.any_until?(incrementer)
          end
        end
        
        def daily_incrementer?
          false
        end
      end

      class ListIncrementer < OccurrenceIncrementer
        attr_accessor :occurrences, :list

        def initialize(rrule, list, parent)
          super(rrule, parent)
          self.list = list
        end
        
        def self.child_incrementer(child_class, rrule, by_part, parent)
          list = rrule.by_rule_list(by_part)
          this_iterator = list ? self.new(rrule, list, parent) : nil
          next_parent = this_iterator || parent
          result = child_class.for_rrule(rrule, next_parent)
          result
        end
        
        def increment(date_time, accept_equal = false)
          self.occurrences ||= occurrences_for(date_time)
          if (next_date_time = next_occurrence(date_time, accept_equal))
            next_date_time
          else
            increment_parent_range(date_time)
          end
        end

        def next_occurrence(date_time, accept_equal = false)
          limit = accept_equal ? 0 : 1
          occurrences.find {|occurrence| (occurrence <=> date_time) >= limit}
        end

        def increment_parent_range(date_time)
          if root_iterator?
            rputs "#{self.class}.increment_parent_range(#{date_time})"
            rputs " range_start_time is #{range_start_time}"
            base = range_advance(range_start_time)
            rputs " range_advance returned #{base}"
            adjusted = adjust_to_start_of_range(base)
            rputs "adjusted is #{adjusted}"
            adjusted
          else
            parent_range_start = beginning_of_range(parent_incrementer.increment_range(date_time))
            self.occurrences = occurrences_for(parent_range_start)
            next_occurrence(parent_range_start, :accept_equal)
          end
        end
        
        def increment_range(date_time)
          increment(date_time, :accept_equal)
        end
        
        def start_new_range(date_time)
          rputs "#{self.class}.start_new_range #{date_time}"
          bor = beginning_of_range(date_time)
          rputs "  beginning_of_range is #{bor}"
          result = super
          rputs "  returning #{result}"
          result
        end
        
        def adjust_to_start_of_range(date_time)
          base = range_advance(range_start_time)
          self.range_start_time = beginning_of_range(base)
        end
        
        def occurrences_for(date_time)
          list.map {|value| date_time.change(varying_time_attribute => value)}
        end

        def range_start_time=(date_time)
          self.occurrences = date_time ? occurrences_for(date_time) : []
          super(beginning_of_range(date_time))
        end
      end

      class FrequencyIncrementer < OccurrenceIncrementer
        attr_accessor :interval
        def initialize(rrule, parent)
          super(rrule, parent)
          self.interval = rrule.interval
        end
        
        def self.child_incrementer(child_class, rrule, freq_str, parent)
          freq_iterator = if rrule.freq == freq_str
            new(rrule, parent)
          else
            nil
          end
          next_parent = freq_iterator || parent
          child_class.for_rrule(rrule, next_parent)
        end
        
        def multiplier
          1
        end
        
        def increment(date_time)
          self.range_start_time = date_time.advance(advance_what => (interval * multiplier))
        end
        
        def increment_range(date_time)
          self.range_start_time ||= date_time
          increment(range_start_time)
        end
        
        def adjust_to_start_of_range(date_time)
          date_time
        end
        
      end

      class SecondlyIncrementer < FrequencyIncrementer

        def self.for_rrule(rrule, parent)
          if rrule.freq == "SECONDLY"
            new(rrule, parent)
          else
            parent
          end
        end

        def advance_what
          :seconds
        end
      end
      
      
      class BySecondIncrementer < ListIncrementer

        def self.for_rrule(rrule, parent)
          child_incrementer(SecondlyIncrementer, rrule, :bysecond, parent)
        end

        def same_range?(old_date_time, new_date_time)
          false
        end
        
        def varying_time_attribute
          :sec
        end
      end

      class MinutelyIncrementer < FrequencyIncrementer
        def self.for_rrule(rrule, parent)
          child_incrementer(BySecondIncrementer, rrule, "MINUTELY", parent)
        end


        def same_range?(old_date_time, new_date_time)
          same_minute?(old_date_time, new_date_time)
        end

        def advance_what
          :minutes
        end
      end
         
      class ByMinuteIncrementer < ListIncrementer
        def self.for_rrule(rrule, parent)
          child_incrementer(MinutelyIncrementer, rrule, :byminute, parent)
        end

        def same_range?(old_date_time, new_date_time)
          same_minute?(old_date_time, new_date_time)
        end

        def range_advance(date_time)
          advance_hour(date_time)
        end
                  
        def beginning_of_range(date_time)
          top_of_hour(date_time)
        end
        
        def varying_time_attribute
          :minute
        end
      end

      class HourlyIncrementer < FrequencyIncrementer
        def self.for_rrule(rrule, parent)
          child_incrementer(ByMinuteIncrementer, rrule, "HOURLY", parent)
        end


        def same_range?(old_date_time, new_date_time)
          same_hour?(old_date_time, new_date_time)
        end

        def advance_what
          :months
        end
      end
      
      
      class ByHourIncrementer < ListIncrementer
        def self.for_rrule(rrule, parent)
          child_incrementer(HourlyIncrementer, rrule, :byhour, parent)
        end
        
        def same_range?(old_date_time, new_date_time)
          same_hour?(old_date_time, new_date_time)
        end

        def range_advance(date_time)
          advance_day(date_time)
        end
                
        def beginning_of_range(date_time)
          first_hour_of_day(date_time)
        end
        
        def varying_time_attribute
          :hour
        end
      end

      class DailyIncrementer < FrequencyIncrementer

        def self.for_rrule(rrule, parent)
          child_incrementer(ByHourIncrementer, rrule, "DAILY", parent)
        end
        
        def daily_incrementer?
          true
        end

        def same_range?(old_date_time, new_date_time)
          same_day?(old_date_time, new_date_time)
        end

        def advance_what
          :days
        end
      end
      

      class ByDayIncrementer < ListIncrementer
                
        def initialize(rrule, list, parent)
          super(rrule, list, parent)
          case rrule.by_day_scope
          when :yearly
            @range_advance_proc = lambda {|date_time| advance_year(date_time)}
            @beginning_of_range_proc = lambda {|date_time| first_day_of_year(date_time)}
            @same_range_proc = lambda {|old_date_time, new_date_time| same_year(old_date_time, new_date_time)}
          when :monthly
            @range_advance_proc = lambda {|date_time| advance_month(date_time)}
            @beginning_of_range_proc = lambda {|date_time| first_day_of_month(date_time)}
            @same_range_proc = lambda {|old_date_time, new_date_time| same_month(old_date_time, new_date_time)}
          when :weekly
            @range_advance_proc = lambda {|date_time| advance_week(date_time)}
            @beginning_of_range_proc = lambda {|date_time| first_day_of_week(rrule.wkst_day, date_time)}
            @same_range_proc = lambda {|old_date_time, new_date_time| same_week(old_date_time, new_date_time)}
          else
            raise "Invalid recurrence rule, byday needs to be scoped by month, week or year"
          end
        end

        def self.for_rrule(rrule, parent)
          child_incrementer(DailyIncrementer, rrule, :byday, parent)
        end
        
        def daily_incrementer?
          true
        end
        
        def occurrences_for(date_time)
          result = list.map {|recurring_day| recurring_day.matches_for(date_time)}.flatten.uniq.sort
          rputs "#{self.class}.occurrences_for(#{date_time}) => #{result.inspect}"
          result
        end

        def same_range?(old_date_time, new_date_time)
          result = @same_range_proc.call(old_date_time, new_date_time)
          rputs "#{self.class}.same_range?(#{old_date_time}, #{new_date_time}) => #{result}"
          result
        end
        
        def range_advance(date_time)
          result = @range_advance_proc.call(date_time)
          rputs "#{self.class}.range_advance(#{date_time}) => #{result}"
          result
         end
        
        def beginning_of_range(date_time)
          # result = @beginning_of_range_proc.call(date_time)
          # rputs "#{self.class}.beginning_of_range(#{date_time}) => #{result}"
          # result
          occurrences_for(date_time).first
        end
        
        def varying_time_attribute
          :day
        end
      end

      module WeeklyBydayMethods
        # byday_list should not change after the first call
        def wdays_from_list(byday_list)
          @wdays ||= byday_list.map {|recurring_day| recurring_day.wday}
        end

        def by_day_occurrences_for(date_time, byday_list)
          candidate = first_of_week = time.start_of_week_with_wkst(wkst)
          result = []
          7.times do |day|
            result << candidate if wdays_from_list(byday_list).include?(candidate.wday)
            candidate = candidate.advance(:days => 1)
          end
          result          
        end
        
      end
      
      class ByNumberedDayIncrementer < ListIncrementer

        def daily_incrementer?
          true
        end

        def same_range?(old_date_time, new_date_time)
          same_day?(old_date_time, new_date_time)
        end
        
        def occurrences_for(date_time)
          if occurrences && @scoping_value == scope_of(date_time)
            occurrences
          else
            @scoping_value ||= scope_of(date_time)
            list.map {|numbered_day| numbered_day.target_date_time_for(date_time)}.uniq.sort
          end
        end
      end
      
      class ByMonthdayIncrementer < ByNumberedDayIncrementer
        def self.for_rrule(rrule, parent)
          child_incrementer(ByDayIncrementer, rrule, :bymonthday, parent)
        end
        
        def scope_of(date_time)
          date_time.month
        end
        
        def range_advance(date_time)
          advance_month(date_time)
        end
        
        def beginning_of_range(date_time)
          first_day_of_month(date_time)
        end
      end
      
      class ByYeardayIncrementer < ByNumberedDayIncrementer
        def self.for_rrule(rrule, parent)
          child_incrementer(ByMonthdayIncrementer, rrule, :byyearday, parent)
        end

        def range_advance(date_time)
          advance_year(date_time)
        end

        def beginning_of_range(date_time)
          first_day_of_year(date_time)
        end
        
        def scope_of(date_time)
          date_time.year
        end
      end

      class WeeklyIncrementer < FrequencyIncrementer

        attr_reader :wkst

        include WeeklyBydayMethods

        def initialize(rrule, parent)
          super(rrule, parent)
          # @wkst = wkst
        end
        
        def self.for_rrule(rrule, parent)
          child_incrementer(ByYeardayIncrementer, rrule, "WEEKLY", parent)
        end

        def range_start_time=(date_time)
          @next_week_start = date_time.advance(:days => 7).change(:hour => 0, :minute => 0, :second => 0)
          super(date_time)
        end

        def same_range?(old_date_time, new_date_time)
          new_date_time < @next_week_start
        end

        def multiplier
          7
        end

        def advance_what
          :days
        end

      end

      class ByWeekNoIncrementer < ListIncrementer
        attr_reader :wkst
        include WeeklyBydayMethods

        def initialize(list, wkst, rrule, parent)
          super(rrule, list, parent)
          @wkst = wkst
        end

        def self.for_rrule(rrule, parent)
          child_incrementer(WeeklyIncrementer, rrule, :byweekno, parent)
        end

        def same_range?(old_date_time, new_date_time)
          same_month?(old_date_time, new_date_time)
        end

        def range_advance(date_time)
          advance_year(date_time)
        end
        
        def beginning_of_range(date_time)
          first_day_of_year(date_time)
        end
        
        def occurrences_for(date_time)
          iso_year, week_one_start = *time.iso_year_and_week_one_start(wkst)
          weeks_in_year_plus_one = date_time.iso_weeks_in_year(wkst)
          weeks = list.map {|wk_num| (wk_num > 0) ? wk_num : weeks_in_year_plus_one + wk_num}.uniq.sort
          weeks.map {|wk_num| week_one_start.advance(:days => (wk_num - 1) * 7)}
        end        
      end

      module MonthlyBydayMethods

        def by_day_occurrences_for(date_time, byday_list)
          byday_list.map {|recurring_day| recurring_day.monthly_matches_for(date_time)}.flatten.uniq.sort
        end
      end

      class MonthlyIncrementer < FrequencyIncrementer

        include MonthlyBydayMethods

        def self.for_rrule(rrule, parent)
          child_incrementer(ByWeekNoIncrementer, rrule, "MONTHLY", parent)
        end

        def same_range?(old_date_time, new_date_time)
          same_month?(old_date_time, new_date_time)
        end

        def advance_what
          :months
        end
      end

      class ByMonthIncrementer < ListIncrementer

        include MonthlyBydayMethods
        
        def self.for_rrule(rrule, parent)
          child_incrementer(MonthlyIncrementer, rrule, :bymonth, parent)
        end

        def same_range?(old_date_time, new_date_time)
          rputs "ByMonthIncrementer.same_range?(#{old_date_time}, #{new_date_time}) = #{same_month?(old_date_time, new_date_time)}"
          same_month?(old_date_time, new_date_time)
        end

        def range_advance(date_time)
          advance_year(date_time)
        end
        
        def beginning_of_range(date_time)
          raw_start = occurrences_for(date_time).first
          if contains_daily_incrementer?
            first_day_of_month(raw_start)
          else
            raw_start
          end
        end
        
        def varying_time_attribute
          :month
        end
      end

      class YearlyIncrementer < FrequencyIncrementer

        def self.from_rrule(rrule, start_time)
          child_incrementer(ByMonthIncrementer, rrule, "YEARLY", nil)
        end

        def same_range?(old_date_time, new_date_time)
          same_year?(old_date_time, new_date_time)
        end

        def advance_what
          :years
        end

        def by_day_occurrences_for(date_time, byday_list)
          byday_list.map {|recurring_day| recurring_day.yearly_matches_for(date_time)}.flatten.uniq.sort
        end
      end
    end
  end
end


