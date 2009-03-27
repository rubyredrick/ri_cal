module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue

      class OccurrenceIncrementer # :nodoc:

        attr_accessor :containing_incrementer
        attr_reader :run_start_time, :leaf_iterator

        def initialize(parent_iterator)
          report_initialize("OccurrenceIncrementer", parent_iterator, leaf_iterator)
          self.containing_incrementer = parent_iterator || OccurrenceIncrementer
          self.leaf_iterator = self
        end
        
        def to_s
          "#{self.class.name.sub("RiCal::PropertyValue::RecurrenceRule::", "")}->#{containing_incrementer.to_s.sub("RiCal::PropertyValue::RecurrenceRule::", "")}"
        end

        def next(date_time)
          rputs "#{self.class}.next(#{date_time})"
          rputs "  called from #{caller[0]}"
          my_next = increment(date_time)
          rputs "#{self.class}.next - my_next is #{my_next}"
          self.run_start_time ||= my_next
          if containing_incrementer.new_range?(my_next)
            rputs "#{self.class}.next - #{containing_incrementer} indicated new_range for #{date_time}"
            containers_next = containing_incrementer.new_range_start(date_time)
            self.run_start_time = containers_next
            rputs "  #{self.class}.next(#{date_time}) returning containers value #{containers_next}"
            containers_next
          else
            rputs "#{self.class}.next(#{date_time}) returning its own value #{my_next}"
            my_next
          end
        end
        
        def next_from_after_run_start(date_time)
          self.run_start_time ||= date_time
          self.next(run_start_time)
        end
        
        def run_start_time=(value)
          # rputs "#{self.class}.run_start_time=#{value}"
          # rputs " called from #{caller[0]}"
          @run_start_time = value
          containing_incrementer.run_start_time = value
        end
        
        def self.run_start_time=(value)
          value
        end

        # The class acts as the ultimate parent, all times are within it's current range
        def self.new_range?(date_time)
          false
        end
        
        # def self.end_of_list(list_incrementer, date_time)
        #   rputs "OccurrenceIncrementer.end_of_list(#{list_incrementer}, #{date_time})"
        #   list_incrementer.next_range(date_time)
        # end
        # 
        def root_iterator?
          containing_incrementer == OccurrenceIncrementer
        end
        
        def leaf_iterator=(value)
          @leaf_iterator = value
          containing_incrementer.leaf_iterator = value
        end
        
        def self.leaf_iterator=(value)
          value
        end
        
        # def end_of_list(list_incrementer, date_time)
        #   rputs "#{self.class}.end_of_list(#{list_incrementer}, #{date_time})"
        #   self.next(date_time)
        # end
        # 
        def self.report_from_rrule_and_container(rrule, container)
          # rputs "#{self}.from_rrule_and_container(.., #{container})"
        end
        
        def report_initialize(*args)
          # rputs "#{self.class}.new(#{args.map {|arg| arg.inspect}.join(", ")})"
        end

        def by_day_occurrences_for(old_date_time, byday_list)
          containing_incrementer.by_day_occurrences_for(old_date_time, byday_list)
        end        

        def new_range?(date_time)
          # rputs "#{self.class}.new_range?(#{date_time})"
          if run_start_time && same_range?(date_time, run_start_time)
            # rputs "  still in range, returning false"
            false
          else
            # rputs "  out of range, returning true"
            true
          end
        end
        
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
        
        def first_monday_of_week(date_time)
          delta = date_time.wday == 0 ? -6 : 1 - date_time.wday
          date_time.advance(:days => delta)
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
        
        def contains_daily_incrementer?
          @contains_daily_incrementer ||= leaf_iterator.any_until?(self) {|iterator| iterator.daily_incrementer?}
        end
        
        def self.any_until?(incrementer)
          false
        end
        
        def any_until?(incrementer)
          rputs "#{self}.any_until?(#{incrementer})"
          if self == incrementer
            rputs " reached the asker, returning false"
            false
          else
            i_am_it = yield self
            rputs "i_am_it = #{i_am_it}"
            i_am_it  || containing_incrementer.any_until?(incrementer)
          end
        end
        
        def daily_incrementer?
          false
        end
      end

      class ListIncrementer < OccurrenceIncrementer
        attr_accessor :occurrences, :list

        def initialize(list, rrule, parent)
          report_initialize("ListIncrementer", list, parent)
          super(parent)
          self.list = list
        end
        
        def self.list_incrementer_child(child_class, rrule, by_part, parent)
          # rputs "#{self}.list_iterator_child(#{child_class}, #{rrule}, #{by_part}, #{parent})"
          list = rrule.by_rule_list(by_part)
          this_iterator = list ? self.new(list, rrule, parent) : nil
          next_parent = this_iterator || parent
          result = child_class.from_rrule_and_parent(rrule, next_parent)
          # rputs "#{self}.list_iterator_child returning #{result}"
          result
        end
        

        def increment(date_time, accept_equal = false)
          self.run_start_time ||= next_range(date_time)
          debug = date_time.month == 2 && date_time.day == 1
          rputs "********************************************" if debug
          rputs "#{self.class}.increment(#{date_time})"
          rputs "    called from #{caller[0]}"
          rputs "    occurrences = #{occurrences.inspect}" if debug
          limit = accept_equal ? 0 : 1
          
          if (next_date_time = occurrences.find {|occurrence| (occurrence <=> date_time) >= limit})
            result = next_date_time
          else
            result = self.run_start_time = next_for_end_of_list(date_time)
          end
          rputs "  #{self.class}.increment result is #{result}"
          rputs "********************************************" if debug
          result
        end
        
        def next_for_end_of_list(date_time)
          rputs "#{self.class}.next_for_end_of_list#{date_time}"
          if self.root_iterator?
            rputs "root incrementer calling new_range_start"
            new_range_start(date_time)
          else
            rputs "getting next from containing incrementer"
            container_next = containing_incrementer.next_from_after_run_start(run_start_time)
            rputs "  containing iterator returned #{container_next}"
            @run_start_time = nil
            result = increment(container_next, :accept_first)
            rputs "  returning incremented result #{result}"
            result
          end
        end
        
        def next_range(date_time)
          result = self.run_start_time = new_range_start(date_time)
          rputs "#{self.class}.next_range(#{date_time}) occurrences = #{occurrences.inspect} returning #{result}"
          result
        end
        
        def new_range_start(date_time)
          rputs "#{self.class}.new_range_start(#{date_time}) run_start_time set #{!!run_start_time}"
          
          if run_start_time
            base = range_advance(run_start_time)
          else
            base = date_time
          end
          rputs " base = #{base}"
          result = beginning_of_range(base)
          rputs " result is #{result}"
          result
        end
        
        def new_range?(date_time)
          self.run_start_time ||= new_range_start(date_time)
          super(date_time)
        end
        
        def same_range?(old_date_time, new_date_time)
          # rputs "ListIncrementer.new_range?(#{old_date_time}, #{new_date_time})"
          result = super(old_date_time, new_date_time)
          # rputs " result is #{result}"
          result
        end
        
        def occurrences_for(date_time)
          result = list.map {|value| date_time.change(varying_time_attribute => value)}
          # rputs "#{self.class}.occurrences_for(#{date_time}) returning #{result.inspect}"
          result
        end

        def run_start_time=(date_time)
          self.occurrences = date_time ? occurrences_for(date_time) : []
          super(beginning_of_range(date_time))
        end
      end

      class FrequencyIncrementer < OccurrenceIncrementer
        attr_accessor :interval
        def initialize(rrule, parent)
          report_initialize("FrequencyIncrementer", parent)
          super(parent)
          self.interval = rrule.interval
        end
        
        def self.freq_iterator_child(child_class, rrule, freq_str, parent)
          # rputs "#{self}.freq_iterator_child(#{child_class}, #{rrule}, #{freq_str.inspect}, #{parent.inspect})"
          freq_iterator = if rrule.freq == freq_str
            new(rrule, parent)
          else
            nil
          end
          # rputs "  freq_iterator is #{freq_iterator}"
          next_parent = freq_iterator || parent
          # rputs "  next_parent is #{next_parent}"
          result = child_class.from_rrule_and_parent(rrule, next_parent)
          # rputs "#{self}.freq_iterator_child returning #{result}"
          result
        end
        
        def multiplier
          1
        end
        
        def increment(date_time)
          date_time.advance(advance_what => (interval * multiplier))
        end
      end

      class SecondlyIncrementer < FrequencyIncrementer

        def self.from_rrule_and_parent(rrule, parent)
          # rputs "SecondlyIncrementer.from_rrule_and_parent(#{rrule}, #{parent})"
          if rrule.freq == "SECONDLY"
            result new(rrule, parent)
          else
            parent
          end
        end

        def advance_what
          :seconds
        end
      end
      
      
      class BySecondIncrementer < ListIncrementer

        def self.from_rrule_and_parent(rrule, parent)
          list_incrementer_child(SecondlyIncrementer, rrule, :bysecond, parent)
        end

        def same_range?(old_date_time, new_date_time)
          false
        end
        
        def varying_time_attribute
          :sec
        end
      end

      class MinutelyIncrementer < FrequencyIncrementer
        def self.from_rrule_and_parent(rrule, parent)
          freq_iterator_child(BySecondIncrementer, rrule, "MINUTELY", parent)
        end


        def same_range?(old_date_time, new_date_time)
          same_minute?(old_date_time, new_date_time)
        end

        def advance_what
          :minutes
        end
      end
         
      class ByMinuteIncrementer < ListIncrementer
        def self.from_rrule_and_parent(rrule, parent)
          list_incrementer_child(MinutelyIncrementer, rrule, :byminute, parent)
        end

        def same_range?(old_date_time, new_date_time)
          same_minute?(old_date_time, new_date_time)
        end

        def range_advance(date_time)
          advance_hour(date_time)
        end
                  
        def beginning_of_range(date_time)
          beginning_of_hour(date_time)
        end
        
        def varying_time_attribute
          :minute
        end
      end

      class HourlyIncrementer < FrequencyIncrementer
        def self.from_rrule_and_parent(rrule, parent)
          freq_iterator_child(ByMinuteIncrementer, rrule, "HOURLY", parent)
        end


        def same_range?(old_date_time, new_date_time)
          same_hour?(old_date_time, new_date_time)
        end

        def advance_what
          :months
        end
      end
      
      
      class ByHourIncrementer < ListIncrementer
        def self.from_rrule_and_parent(rrule, parent)
          list_incrementer_child(HourlyIncrementer, rrule, :byhour, parent)
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

        def self.from_rrule_and_parent(rrule, parent)
          freq_iterator_child(ByHourIncrementer, rrule, "DAILY", parent)
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
                
        def initialize(list, rrule, parent)
          report_initialize("ByDayIncrementer", parent)
          super
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
            @beginning_of_range_proc = lambda {|date_time| first_monday_of_week(date_time)}
            @same_range_proc = lambda {|old_date_time, new_date_time| same_week(old_date_time, new_date_time)}
          else
            raise "Invalid recurrence rule, byday needs to be scoped by month, week or year"
          end
        end

        def self.from_rrule_and_parent(rrule, parent)
          list_incrementer_child(DailyIncrementer, rrule, :byday, parent)
        end
        
        def daily_incrementer?
          true
        end
        
        def occurrences_for(date_time)
          result = list.map {|recurring_day| recurring_day.matches_for(date_time)}.flatten.uniq.sort
          rputs "ByDayIncrementer.occurrences_for(#{date_time}) returning #{result.map {|d| d.to_s}.join(", ")}"
          result
        end

        def same_range?(old_date_time, new_date_time)
          @same_range_proc.call(old_date_time, new_date_time)
        end
        
        def range_advance(date_time)
          @range_advance_proc.call(date_time)
         end
        
        def beginning_of_range(date_time)
          @beginning_of_range_proc.call(date_time)
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
            result = list.map {|numbered_day| numbered_day.target_date_time_for(date_time)}.uniq.sort
            rputs "#{self.class}.occurrences_for(date_time) computed scoping_value of #{@scoping_value}"
            rputs "    result is #{result.map {|e| e.to_s}.join(", ")}"
            result
          end
        end
      end
      
      class ByMonthdayIncrementer < ByNumberedDayIncrementer
        def self.from_rrule_and_parent(rrule, parent)
          list_incrementer_child(ByDayIncrementer, rrule, :bymonthday, parent)
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
        def self.from_rrule_and_parent(rrule, parent)
          list_incrementer_child(ByMonthdayIncrementer, rrule, :byyearday, parent)
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
          report_initialize("WeeklyIncrementer", parent)
          super(rrule, parent)
          # @wkst = wkst
        end
        
        def self.from_rrule_and_parent(rrule, parent)
          freq_iterator_child(ByYeardayIncrementer, rrule, "WEEKLY", parent)
        end

        def run_start_time=(date_time)
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
          report_initialize("ByWeekNoIncrementer", list, wkst, parent)
          super(list, rrule, parent_container)
          @wkst = wkst
        end

        def self.from_rrule_and_parent(rrule, parent)
          list_incrementer_child(WeeklyIncrementer, rrule, :byweekno, parent)
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

        def self.from_rrule_and_parent(rrule, parent)
          freq_iterator_child(ByWeekNoIncrementer, rrule, "MONTHLY", parent)
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

        def self.from_rrule_and_parent(rrule, parent)
          list_incrementer_child(MonthlyIncrementer, rrule, :bymonth, parent)
        end

        def same_range?(old_date_time, new_date_time)
          # rputs "ByMonthIncrementer.same_range?(#{old_date_time}, #{new_date_time}) = #{same_month?(old_date_time, new_date_time)}"
          same_month?(old_date_time, new_date_time)
        end

        def range_advance(date_time)
          advance_year(date_time)
        end
        
        def beginning_of_range(date_time)
          if contains_daily_incrementer?
            first_day_of_year(date_time)
          else
            first_month_of_year(date_time)
          end
        end
        
        def varying_time_attribute
          :month
        end
      end

      class YearlyIncrementer < FrequencyIncrementer

        def self.from_rrule(rrule)
          freq_iterator_child(ByMonthIncrementer, rrule, "YEARLY", nil)
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


