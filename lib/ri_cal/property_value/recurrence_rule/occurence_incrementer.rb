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

        attr_accessor :sub_cycle_incrementer, :cycle_start
        attr_accessor :contains_daily_incrementer
        attr_reader :leaf_iterator

        include RangePredicates
        include TimeManipulation

        def initialize(rrule, sub_cycle_incrementer)
          self.sub_cycle_incrementer = sub_cycle_incrementer
          if sub_cycle_incrementer
            self.contains_daily_incrementer = sub_cycle_incrementer.daily_incrementer? ||
            sub_cycle_incrementer.contains_daily_incrementer?
          end
        end

        def to_s
          if sub_cycle_incrementer
            "#{self.short_name}->#{sub_cycle_incrementer}"
          else
            self.short_name
          end
        end
        
        def short_name
          @short_name ||= self.class.name.split("::").last
        end

        def next_time(previous_occurrence)
          rputs "#{self.short_name}.next_time(#{previous_occurrence})"
          sub_occurrence = next_suboccurrence(previous_occurrence)
          rputs "  sub_occurrence is #{sub_occurrence}"
          if sub_occurrence
            sub_occurrence
          else
            result = increment(previous_occurrence)
            adjust_to_subcycle(previous_occurrence, result)
          end
        end
        
        def adjust_to_subcycle(previous_occurrence, candidate)
          if sub_cycle_incrementer
            rputs "#{self.short_name}.adjust_to_subcycle(#{previous_occurrence}, #{candidate})"
            sub_occurrence = sub_cycle_incrementer.next_suboccurrence_candidate(previous_occurrence, self)
            rputs " first sub_occurrence is #{sub_occurrence} cycle_start is #{cycle_start}"
            while !sub_occurrence
              self.cycle_start = start_of_next_cycle(previous_occurrence)
              rputs " cycle_start is now #{cycle_start}"
              sub_occurrence = sub_cycle_incrementer.next_suboccurrence_candidate(previous_occurrence, self)
              rputs " sub_occurrence is now #{sub_occurrence}"
            end
            sub_occurrence
          else
            candidate
          end
        end

        def next_suboccurrence(previous_occurrence)
          if sub_cycle_incrementer
            self.cycle_start ||= previous_occurrence
            candidate = sub_cycle_incrementer.next_suboccurrence_candidate(previous_occurrence, self)
          else
            nil
          end
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
        attr_accessor :occurrences, :list, :slower_cycle_start

        def initialize(rrule, list, sub_cycle_incrementer)
          super(rrule, sub_cycle_incrementer)
          self.list = list
        end

        def next_suboccurrence_candidate(previous_occurrence, outer_incrementer)
          rputs "  #{self.short_name}.next_suboccurrence_candidate(#{previous_occurrence})"
          outer_cycle_start = outer_incrementer.cycle_start
          rputs "  #{self.short_name}.next_suboccurrence_candidate(#{previous_occurrence}) cycle_start is #{cycle_start}"
          unless outer_cycle_start == slower_cycle_start
            self.slower_cycle_start = outer_cycle_start
            self.cycle_start = first_occurrence_for(outer_cycle_start)
          end
          sub_occurrence = next_suboccurrence(previous_occurrence)
          if sub_occurrence && sub_occurrence > previous_occurrence
            rputs "  #{self.short_name}.next_suboccurrence_candidate candidate is #{sub_occurrence}"
            candidate = sub_occurrence
          else
            rputs "  #{self.short_name} occurrences are #{occurrences.inspect}"
            candidate = occurrences.find {|occurrence| occurrence > previous_occurrence} || start_of_next_cycle(previous_occurrence)
          end              
          if outer_incrementer.same_cycle?(candidate)
            rputs "same cycle in outer_incrementer returning #{candidate}"
            candidate
          else
            rputs "different cycle returning nil"
            nil
          end
        end

        def increment(previous_occurrence)
          self.cycle_start ||= previous_occurrence
          occurrences.find {|occurrence| occurrence > previous_occurrence} || start_of_next_cycle(previous_occurrence)
        end        

        def next_time(previous_occurrence)
          result = super
          rputs "#{self.short_name}.next_time(#{previous_occurrence}) super gave #{result}, self.cycle_start is #{cycle_start}"
          if same_cycle?(result)
            result
          else
            rputs "ran out of current range"
            # We ran out of the current range
            start_of_next_cycle(previous_occurrence)
          end
        end

        def start_of_next_cycle(previous_occurrence)
          adv_cycle = advance_cycle
          rputs "#{self.short_name}.start_of_next_cycle(#{previous_occurrence}) adv_cycle = #{adv_cycle}"
          rputs "  cycle_start was #{cycle_start}"
          self.cycle_start = first_occurrence_for(adv_cycle)
          rputs "  cycle_start is now #{cycle_start}"
          cycle_start
        end

        def self.conditional_incrementer(rrule, by_part, sub_cycle_class)
          sub_cycle_incrementer = sub_cycle_class.for_rrule(rrule)
          list = rrule.by_rule_list(by_part)
          if list
            new(rrule, list, sub_cycle_incrementer)
          else
            sub_cycle_incrementer
          end
        end


        def occurrences_for(date_time)
          list.map {|value| date_time.change(varying_time_attribute => value)}
        end

        def first_occurrence_for(date_time)
          date_time.change(varying_time_attribute => list.first)
        end

        def cycle_start=(date_time)
          self.occurrences = date_time ? occurrences_for(date_time) : []
          super
        end
      end

      class FrequencyIncrementer < OccurrenceIncrementer
        attr_accessor :interval
        def initialize(rrule, sub_cycle_incrementer)
          super(rrule, sub_cycle_incrementer)
          self.interval = rrule.interval
        end

        def self.conditional_incrementer(rrule, freq_str, sub_cycle_class)
          sub_cycle_incrementer = sub_cycle_class.for_rrule(rrule)
          if rrule.freq == freq_str
            new(rrule, sub_cycle_incrementer)
          else
            sub_cycle_incrementer
          end
        end

        def multiplier
          1
        end

        def increment(previous_occurrence)
          self.cycle_start = previous_occurrence.advance(advance_what => (interval * multiplier))
        end

        alias_method :start_of_next_cycle, :increment

        def next_suboccurrence_candidate(previous_occurrence, outer_incrementer)
          candidate = increment(previous_occurrence)
          rputs "#{self.short_name}.next_suboccurrence_candidate"
          rputs "  previous_occurrence=#{previous_occurrence}"
          rputs "  outer_incrementer.cycle_start is #{outer_incrementer.cycle_start}"
          rputs "  candidate is #{candidate}"
          if outer_incrementer.same_cycle?(candidate)
            rputs " HIT"
            candidate
          else
            rputs " MISS"
            nil #outer_incrementer.start_of_next_cycle(previous_occurrence)
          end
        end
      end

      class SecondlyIncrementer < FrequencyIncrementer

        def self.for_rrule(rrule)
          if rrule.freq == "SECONDLY"
            new(rrule, nil)
          else
            nil
          end
        end

        def advance_what
          :seconds
        end
      end


      class BySecondIncrementer < ListIncrementer

        def self.for_rrule(rrule)
          conditional_incrementer(rrule, :bysecond, SecondlyIncrementer)
        end

        def same_cycle?(date_time)
          false
        end

        def varying_time_attribute
          :sec
        end

        def advance_cycle
          advance_hour(cycle_start)
        end
      end

      class MinutelyIncrementer < FrequencyIncrementer
        def self.for_rrule(rrule)
          conditional_incrementer(rrule, "MINUTELY", BySecondIncrementer)
        end


        def same_cycle?(date_time)
          same_minute?(cycle_start, new_date_time)
        end

        def advance_what
          :minutes
        end
      end

      class ByMinuteIncrementer < ListIncrementer
        def self.for_rrule(rrule)
          conditional_incrementer(rrule, :byminute, MinutelyIncrementer)
        end

        def same_cycle?(date_time)
          same_minute?(cycle_start, new_date_time)
        end

        def advance_cycle
          top_of_hour(advance_hour(cycle_start))
        end

        def beginning_of_range(date_time)
          top_of_hour(date_time)
        end

        def varying_time_attribute
          :minute
        end
      end

      class HourlyIncrementer < FrequencyIncrementer
        def self.for_rrule(rrule)
          conditional_incrementer(rrule, "HOURLY", ByMinuteIncrementer)
        end


        def same_cycle?(date_time)
          same_hour?(cycle_start, new_date_time)
        end

        def advance_what
          :months
        end
      end


      class ByHourIncrementer < ListIncrementer
        def self.for_rrule(rrule)
          conditional_incrementer(rrule, :byhour, HourlyIncrementer)
        end

        def same_cycle?(date_time)
          same_hour?(cycle_start, new_date_time)
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

        def advance_cycle
          first_hour_of_day(advance_day(cycle_start))
        end
      end

      class DailyIncrementer < FrequencyIncrementer

        def self.for_rrule(rrule)
          conditional_incrementer(rrule, "DAILY", ByHourIncrementer)
        end

        def daily_incrementer?
          true
        end

        def same_cycle?(date_time)
          same_day?(cycle_start, new_date_time)
        end

        def advance_what
          :days
        end
      end
      class ByNumberedDayIncrementer < ListIncrementer

        def daily_incrementer?
          true
        end

        def same_cycle?(date_time)
          scope_of(cycle_start)== scope_of(new_date_time)
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
        
        def first_occurrence_for(date_time)
          occurrences_for(date_time).first
        end

        def candidate_acceptible?(candidate)
          list.any? {|by_part| by_part.include?(candidate)}
        end
      end

      class ByMonthdayIncrementer < ByNumberedDayIncrementer
        def self.for_rrule(rrule)
          conditional_incrementer(rrule, :bymonthday, DailyIncrementer)
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

        def advance_cycle
          first_day_of_month(advance_month(cycle_start))
        end
      end

      class ByYeardayIncrementer < ByNumberedDayIncrementer
        def self.for_rrule(rrule)
          conditional_incrementer(rrule, :byyearday, ByMonthdayIncrementer)
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

        def advance_cycle
          first_day_of_year(advance_year(cycle_start))
        end
      end

      class ByDayIncrementer < ListIncrementer

        def initialize(rrule, list, parent)
          super(rrule, list, parent)
          case rrule.by_day_scope
          when :yearly
            @cycle_advance_proc = lambda {first_day_of_year(advance_year(cycle_start))}
            @same_cycle_proc = lambda {|date_time| same_year?(cycle_start, date_time)}
            @first_day_proc = lambda {|date_time| first_day_of_year(date_time)}
          when :monthly
            @cycle_advance_proc = lambda {first_day_of_month(advance_month(cycle_start))}
            @same_cycle_proc = lambda {|date_time| same_month?(cycle_start, date_time)}
            @first_day_proc = lambda {|date_time| first_day_of_month(date_time)}
          when :weekly
            @cycle_advance_proc = lambda {first_day_of_week(rrule.wkst_day, advance_week(cycle_start))}
            @same_cycle_proc = lambda {|date_time| same_week?(rrule.wkst_day, cycle_start, date_time)}
            @first_day_proc = lambda {|date_time| first_day_of_week(rrule.wkst_day, date_time)}
          else
            raise "Invalid recurrence rule, byday needs to be scoped by month, week or year"
          end
        end

        def self.for_rrule(rrule)
          conditional_incrementer(rrule, :byday, ByYeardayIncrementer)
        end

        def daily_incrementer?
          true
        end

        def occurrences_for(date_time)
          first_day = @first_day_proc.call(date_time)
          result = list.map {|recurring_day| recurring_day.matches_for(first_day)}.flatten.uniq.sort
          result
        end

        def first_occurrence_for(date_time)
          occurrences_for(date_time).first
        end

        def candidate_acceptible?(candidate)
          list.any? {|recurring_day| recurring_day.include?(candidate)}
        end

        def same_cycle?(date_time)
          @same_cycle_proc.call(cycle_start, date_time)
        end

        def varying_time_attribute
          :day
        end

        def advance_cycle
          @cycle_advance_proc.call
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

        def self.for_rrule(rrule)
          conditional_incrementer(rrule, "WEEKLY", ByDayIncrementer)
        end

        def same_cycle?(date_time)
          same_week?(wkst, cycle_start, date_time)
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

        def self.for_rrule(rrule)
          conditional_incrementer(rrule, :byweekno, WeeklyIncrementer)
        end

        def same_cycle?(date_time)
          same_month?(cycle_start, date_time)
        end

        def range_advance(date_time)
          advance_year(date_time)
        end

        def beginning_of_range(date_time)
          first_day_of_year(date_time)
        end

        def occurrences_for(date_time)
          iso_year, week_one_start = *date_time.iso_year_and_week_one_start(wkst)
          weeks_in_year_plus_one = date_time.iso_weeks_in_year(wkst)
          weeks = list.map {|wk_num| (wk_num > 0) ? wk_num : weeks_in_year_plus_one + wk_num}.uniq.sort
          weeks.map {|wk_num| week_one_start.advance(:days => (wk_num - 1) * 7)}
        end

        def first_occurrence_for(date_time)
          occurrences_for(date_time).first
        end

        def candidate_acceptible?(candidate)
          list.include?(candidate.iso_week_num(wkst))
        end

        def advance_cycle
          first_day_of_year(advance_year(cycle_start))
        end
      end

      module MonthlyBydayMethods

        def by_day_occurrences_for(date_time, byday_list)
          byday_list.map {|recurring_day| recurring_day.monthly_matches_for(date_time)}.flatten.uniq.sort
        end
      end

      class MonthlyIncrementer < FrequencyIncrementer

        include MonthlyBydayMethods

        def self.for_rrule(rrule)
          conditional_incrementer(rrule, "MONTHLY", ByWeekNoIncrementer)
        end

        def same_cycle?(date_time)
          same_month?(cycle_start, date_time)
        end

        def advance_what
          :months
        end
      end

      class ByMonthIncrementer < ListIncrementer

        include MonthlyBydayMethods

        def self.for_rrule(rrule)
          conditional_incrementer(rrule, :bymonth, MonthlyIncrementer)
        end

        def same_cycle?(date_time)
          same_month?(cycle_start, date_time)
        end

        def occurrences_for(date_time)
          list.map {|value| date_time.in_month(value)}
        end

        def first_occurrence_for(date_time)
          date_time.in_month(list.first)
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

        def advance_cycle
          first_day_of_year(advance_year(cycle_start))
        end
      end

      class YearlyIncrementer < FrequencyIncrementer

        def self.from_rrule(rrule, start_time)
          conditional_incrementer(rrule, "YEARLY", ByMonthIncrementer)
        end

        def same_cycle?(date_time)
          same_year?(cycle_start, date_time)
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
