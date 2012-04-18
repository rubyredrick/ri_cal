module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue
      #- c2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license
      #
      class OccurrenceIncrementer # :nodoc:

        attr_accessor :sub_cycle_incrementer, :current_occurrence, :outer_range
        attr_accessor :outer_incrementers
        attr_accessor :contains_daily_incrementer, :contains_weeknum_incrementer
        attr_reader :leaf_iterator
        parent_path = "ri_cal/property_value/recurrence_rule/occurrence_incrementer"

        autoload :ByDayIncrementer, "#{parent_path}/by_day_incrementer.rb"
        autoload :ByHourIncrementer, "#{parent_path}/by_hour_incrementer.rb"
        autoload :ByMinuteIncrementer, "#{parent_path}/by_minute_incrementer.rb"
        autoload :ByMonthIncrementer, "#{parent_path}/by_month_incrementer.rb"
        autoload :ByMonthdayIncrementer, "#{parent_path}/by_monthday_incrementer.rb"
        autoload :ByNumberedDayIncrementer, "#{parent_path}/by_numbered_day_incrementer.rb"
        autoload :BySecondIncrementer, "#{parent_path}/by_second_incrementer.rb"
        autoload :ByYeardayIncrementer, "#{parent_path}/by_yearday_incrementer.rb"
        autoload :ByWeekNoIncrementer, "#{parent_path}/by_weekno_incrementer.rb"
        autoload :DailyIncrementer, "#{parent_path}/daily_incrementer.rb"
        autoload :FrequencyIncrementer, "#{parent_path}/frequency_incrementer.rb"
        autoload :HourlyIncrementer, "#{parent_path}/hourly_incrementer.rb"
        autoload :ListIncrementer, "#{parent_path}/list_incrementer.rb"
        autoload :MinutelyIncrementer, "#{parent_path}/minutely_incrementer.rb"
        autoload :MonthlyIncrementer, "#{parent_path}/monthly_incrementer.rb"
        autoload :NullSubCycleIncrementer, "#{parent_path}/null_sub_cycle_incrementer.rb"
        autoload :SecondlyIncrementer, "#{parent_path}/secondly_incrementer.rb"
        autoload :WeeklyIncrementer, "#{parent_path}/weekly_incrementer.rb"
        autoload :YearlyIncrementer, "#{parent_path}/yearly_incrementer.rb"

        include RecurrenceRule::TimeManipulation

        def initialize(rrule, sub_cycle_incrementer)
          self.sub_cycle_incrementer = sub_cycle_incrementer
          @outermost = true
          self.outer_incrementers = []
          if sub_cycle_incrementer
            self.contains_daily_incrementer = sub_cycle_incrementer.daily_incrementer? ||
              sub_cycle_incrementer.contains_daily_incrementer?
            self.contains_weeknum_incrementer = sub_cycle_incrementer.weeknum_incrementer?||
              sub_cycle_incrementer.contains_weeknum_incrementer?
            sub_cycle_incrementer.add_outer_incrementer(self)
          else
            self.sub_cycle_incrementer = NullSubCycleIncrementer
          end
        end

        def self.from_rrule(recurrence_rule, start_time)
          YearlyIncrementer.from_rrule(recurrence_rule, start_time)
        end

        def add_outer_incrementer(incrementer)
          @outermost = false
          self.outer_incrementers << incrementer
          sub_cycle_incrementer.add_outer_incrementer(incrementer)
        end

        def outermost?
          @outermost
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

        # Return the next time after previous_occurrence generated by this incrementer
        # But the occurrence is outside the current cycle of any outer incrementer(s) return
        # nil which will cause the outer incrementer to step to its next cycle
        def next_time(previous_occurrence)
          @previous_occurrence = previous_occurrence
          if current_occurrence
            sub_occurrence = @sub_cycle_incrementer.next_time(previous_occurrence)
          else #first time
            sub_occurrence = @sub_cycle_incrementer.first_sub_occurrence(previous_occurrence, update_cycle_range(previous_occurrence))
          end
          if sub_occurrence
            candidate = sub_occurrence
          else
            candidate = next_cycle(previous_occurrence)
          end
          if in_outer_cycle?(candidate)
            candidate
          else
            nil
          end
        end

        def update_cycle_range(date_time)
          self.current_occurrence = date_time
          (date_time..end_of_occurrence(date_time))
        end

        def in_outer_cycle?(candidate)
          candidate && (outer_range.nil? || (outer_range.first <= candidate && outer_range.last >= candidate))
        end

        def first_sub_occurrence(previous_occurrence, outer_cycle_range)
          first_within_outer_cycle(previous_occurrence, outer_cycle_range)
        end

        # Advance to the next cycle, if the result is within the current cycles of all outer incrementers
        def next_cycle(previous_occurrence)
          raise "next_cycle is a subclass responsibility"
        end

        def contains_daily_incrementer?
          @contains_daily_incrementer
        end

        def daily_incrementer?
          false
        end

        def contains_weeknum_incrementer?
          @contains_weeknum_incrementer
        end

        def weeknum_incrementer?
          false
        end
      end
    end
  end
end