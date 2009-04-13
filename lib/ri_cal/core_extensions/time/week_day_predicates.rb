module RiCal
  module CoreExtensions
    module Time
      # Provide predicate methods for use by the RiCal gem
      # This module is included by Time, Date, and DateTime
      module WeekDayPredicates
        
        # Determine the equivalent time on the day which falls on a particular weekday of the same year as the receiver
        #
        # == Parameters
        # n:: the ordinal number being requested
        # which_wday:: the weekday using Ruby time conventions, i.e. 0 => Sunday, 1 => Monday, ...
        
        # e.g. to obtain the 2nd Monday of the receivers year use
        #
        #   time.nth_wday_in_year(2, 1)
        def nth_wday_in_year(n, which_wday)
          if n > 0
            first_of_year = self.to_ri_cal_property_value.change(:month => 1, :day => 1)
            first_in_year = first_of_year.advance(:days => (which_wday - first_of_year.wday + 7) % 7)
            first_in_year.advance(:days => (7*(n - 1)))
          else
            december25 = self.to_ri_cal_property_value.change(:month => 12, :day => 25)
            last_in_year = december25.advance(:days => (which_wday - december25.wday + 7) % 7)
            last_in_year.advance(:days => (7 * (n + 1)))
          end
        end
        
        # A predicate to determine whether or not the receiver falls on a particular weekday of its year.
        # 
        # See #nth_wday_in_year
        #
        # == Parameters
        # n:: the ordinal number being requested
        # which_wday:: the weekday using Ruby time conventions, i.e. 0 => Sunday, 1 => Monday, ...
        def nth_wday_in_year?(n, which_wday)
          target = nth_wday_in_year(n, which_wday)
          [self.year, self.mon, self.day] == [target.year, target.mon, target.day]
        end

        # Determine the day which falls on a particular weekday of the same month as the receiver
        #
        # == Parameters
        # n:: the ordinal number being requested
        # which_wday:: the weekday using Ruby time conventions, i.e. 0 => Sunday, 1 => Monday, ...
        
        # e.g. to obtain the 3nd Tuesday of the receivers month use
        #
        #   time.nth_wday_in_month(2, 2)
        def nth_wday_in_month(n, which_wday)
          first_of_month = self.to_ri_cal_property_value.change(:day => 1)
          first_in_month = first_of_month.advance(:days => (which_wday - first_of_month.wday))
          first_in_month = first_in_month.advance(:days => 7) if first_in_month.month != first_of_month.month
          if n > 0
            first_in_month.advance(:days => (7*(n - 1)))
          else
            possible = first_in_month.advance(:days => 21)
            possible = possible.advance(:days => 7) while possible.month == first_in_month.month
            last_in_month = possible.advance(:days => - 7)
            (last_in_month.advance(:days => - (7*(n.abs - 1))))
          end
        end
              
        # A predicate to determine whether or not the receiver falls on a particular weekday of its month.
        #
        # == Parameters
        # n:: the ordinal number being requested
        # which_wday:: the weekday using Ruby time conventions, i.e. 0 => Sunday, 1 => Monday, ...
        def nth_wday_in_month?(n, which_wday)
          target = nth_wday_in_month(n, which_wday)
          [self.year, self.month, self.day] == [target.year, target.month, target.day]
        end
        
        # Return a DateTime which is the beginning of the first day on or before the receiver
        # with the specified wday
        def start_of_week_with_wkst(wkst)
           wkst ||= 1
           date = ::Date.civil(self.year, self.month, self.day)
           date -= 1 while date.wday != wkst
           date
        end
      end
    end
  end
end