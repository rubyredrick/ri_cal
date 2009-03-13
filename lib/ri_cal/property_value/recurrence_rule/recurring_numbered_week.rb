module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue
      class RecurringNumberedWeek < NumberedSpan # :nodoc:
        def last
          53
        end
         
        # return a list of times which match the time parameter within the scope of the RecurringDay
        def matches_for(time, wkst = default_wkst)
          iso_year, week_one_start = *time.iso_year_and_week_one_start(wkst)
          week_start = week_one_start + 7 * (adjusted_iso_weeknum(week_one_start) - 1)
          if week_start.iso_year(wkst) == iso_year
            (0..6).map {|d| week_start + d}
          else
            []
          end
        end
        
        def rule_wkst
          @rule && rule.wkst_day
        end
        
        def default_wkst
          rule_wkst || 1
        end
        
        def adjusted_iso_weeknum(date_or_time)
          if @source > 0
            @source
          else
            date_or_time.iso_weeks_in_year(wkst) + @source + 1
          end
        end
        
        def include?(date_or_time, wkst=default_wkst)
          date_or_time.iso_week_num(wkst) == adjusted_iso_weeknum(date_or_time)
        end
      end
    end
  end
end