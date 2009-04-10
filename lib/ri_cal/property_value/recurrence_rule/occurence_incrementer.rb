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

        def same_week?(wkst, old_date_time, new_date_time)
          diff = (new_date_time.to_datetime - (old_date_time.at_start_of_week_with_wkst(wkst).to_datetime))
          diff.between?(0,6)
        end

        def same_day?(old_date_time, new_date_time)
          (old_date_time.day == new_date_time.day) && same_month?(old_date_time, new_date_time)
        end

        def same_hour?(old_date_time, new_date_time)
          (old_date_time.hour == new_date_time.hour) && same_day?(old_date_time, new_date_time)
        end

        def same_minute?(old_date_time, new_date_time)
          (old_date_time.min == new_date_time.min) && same_hour?(old_date_time, new_date_time)
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
        attr_accessor :contains_daily_incrementer
        attr_reader :leaf_iterator

        include RangePredicates
        include TimeManipulation

        def initialize(rrule, parent_iterator)
          if parent_iterator
            self.parent_incrementer = parent_iterator
            parent_incrementer.contains_daily_incrementer ||= daily_incrementer?
          else
            self.parent_incrementer = OccurrenceIncrementer
          end
          self.leaf_iterator = self
        end

        def to_s
          "#{self.class.name.sub("RiCal::PropertyValue::RecurrenceRule::", "")}->#{parent_incrementer.to_s.sub("RiCal::PropertyValue::RecurrenceRule::", "")}"
        end

        def start_new_range(date_time)
          parent_incrementer.start_new_range(date_time)
        end

        def self.start_new_range(date_time)
          date_time
        end

        def self.same_range?(old_date_time, new_date_time)
          true
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

        def self.filter_candidate(candidate)
          true
        end

        def by_day_occurrences_for(old_date_time, byday_list)
          parent_incrementer.by_day_occurrences_for(old_date_time, byday_list)
        end        

        def contains_daily_incrementer?
          @contains_daily_incrementer
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

        def next(date_time)
          rputs "#{self.class}.next(#{date_time})"
          unless range_start_time
            rputs "initializing range_start_time"
            self.range_start_time = date_time
          end
          increment(date_time)
        end


        def increment(date_time, accept_equal = false)
          rputs "#{self.class}.increment(#{date_time}, #{accept_equal})"
          self.occurrences ||= occurrences_for(date_time)
          unless same_range?(range_start_time, date_time)
            self.range_start_time = date_time
            accept_equal = true
          end
          next_occurrence(date_time, accept_equal)
        end

        def next_occurrence(date_time, accept_equal = false)
          limit = accept_equal ? 0 : 1
          candidate = occurrences.find {|occurrence| (occurrence <=> date_time) >= limit}
          rputs "#{self.class}.next_occurrence(#{date_time}, #{accept_equal})"
          rputs "  first candidate is #{candidate}"
          until parent_incrementer.filter_candidate(candidate)
            candidate = occurrences.find {|occurrence| (occurrence > candidate)}
            rputs "candidate is now #{candidate}"
          end
          if candidate
            puts "returning #{candidate}"
            candidate
          else
            next_range_start(occurrences.last)
          end
        end

        def filter_candidate(candidate)
          if range_start_time && candidate
            candidate_acceptible?(candidate)
          else
            true
          end
        end

        def candidate_acceptible?(candidate)
          list.include?(candidate.send(varying_time_attribute))
        end

        def next_range_start(date_time)
          my_next_range_start = range_advance(range_start_time)
          rputs "#{self.class}.next_range_start(#{date_time}) my_next_range_start is #{my_next_range_start}"
          if parent_incrementer.same_range?(date_time, my_next_range_start)
            rputs " same range in parent"
            self.range_start_time = my_next_range_start
          else
            rputs " parent said no to same range, current range_start_time is #{range_start_time}"
            self.range_start_time = parent_incrementer.next(date_time)
          end
          rputs "range_start_time is now #{range_start_time}"
          result = increment(range_start_time, :accept_equal)
          rputs "returning #{result}"
          result
        end

        def start_new_range(date_time)
          rputs "#{self.class}.start_new_range #{date_time}"
          bor = beginning_of_range(date_time)
          rputs "  beginning_of_range is #{bor}"
          result = super
          rputs "  returning #{result}"
          result
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

        def next(date_time)
          self.range_start_time ||= date_time
          my_next = date_time.advance(advance_what => (interval * multiplier))
          if parent_incrementer.same_range?(range_start_time, my_next)
            my_next
          else
            self.range_start_time = parent_incrementer.range_advance(range_start_time)
          end
        end

        def filter_candidate(candidate)
          true
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
      class ByNumberedDayIncrementer < ListIncrementer

        def daily_incrementer?
          true
        end

        def same_range?(old_date_time, new_date_time)
          scope_of(old_date_time)== scope_of(new_date_time)
        end

        def occurrences_for(date_time)
          if occurrences && @scoping_value == scope_of(date_time)
             occurrences
          else
            @scoping_value = scope_of(date_time)
            self.occurrences = list.map {|numbered_day| numbered_day.target_date_time_for(date_time)}.uniq.sort
            occurrences
          end
        end

        def candidate_acceptible?(candidate)
          list.any? {|by_part| by_part.include?(candidate)}
        end                
      end

      class ByMonthdayIncrementer < ByNumberedDayIncrementer
        def self.for_rrule(rrule, parent)
          child_incrementer(DailyIncrementer, rrule, :bymonthday, parent)
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

      class ByDayIncrementer < ListIncrementer

        def initialize(rrule, list, parent)
          super(rrule, list, parent)
          case rrule.by_day_scope
          when :yearly
            @range_advance_proc = lambda {|date_time| advance_year(date_time)}
            @beginning_of_range_proc = lambda {|date_time| first_day_of_year(date_time)}
            @same_range_proc = lambda {|old_date_time, new_date_time| same_year?(old_date_time, new_date_time)}
          when :monthly
            @range_advance_proc = lambda {|date_time| advance_month(date_time)}
            @beginning_of_range_proc = lambda {|date_time| first_day_of_month(date_time)}
            @same_range_proc = lambda {|old_date_time, new_date_time| same_month?(old_date_time, new_date_time)}
          when :weekly
            @range_advance_proc = lambda {|date_time| advance_week(date_time)}
            @beginning_of_range_proc = lambda {|date_time| first_day_of_week(rrule.wkst_day, date_time)}
            @same_range_proc = lambda {|old_date_time, new_date_time| same_week?(rrule.wkst_day, old_date_time, new_date_time)}
          else
            raise "Invalid recurrence rule, byday needs to be scoped by month, week or year"
          end
        end

        def self.for_rrule(rrule, parent)
          child_incrementer(ByYeardayIncrementer, rrule, :byday, parent)
        end

        def daily_incrementer?
          true
        end

        def occurrences_for(date_time)
          result = list.map {|recurring_day| recurring_day.matches_for(date_time)}.flatten.uniq.sort
          rputs "#{self.class}.occurrences_for(#{date_time}) => #{result.inspect}"
          result
        end

        def candidate_acceptible?(candidate)
          list.any? {|recurring_day| recurring_day.include?(candidate)}
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

      class WeeklyIncrementer < FrequencyIncrementer

        attr_reader :wkst

        include WeeklyBydayMethods

        def initialize(rrule, parent)
          @wkst = rrule.wkst_day
          super(rrule, parent)
        end

        def self.for_rrule(rrule, parent)
          child_incrementer(ByDayIncrementer, rrule, "WEEKLY", parent)
        end

        def same_range?(old_date_time, new_date_time)
          same_week?(wkst, old_date_time, new_date_time)
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

        def candidate_acceptible?(candidate)
          list.include?(candidate.iso_week_num(wkst))
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
          new_date_time <= occurrences_for(old_date_time).last.end_of_month
        end

        def occurrences_for(date_time)
          list.map {|value| date_time.in_month(value)}
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
