module RiCal
  module CoreExtensions
    module Time
      # Provide predicate methods for use by the RiCal gem
      # This module is included by Time, Date, and DateTime
      module WeekDayPredicates
        
        # Determine the day which falls on a particular weekday of the same year as the receiver
        #
        # == Parameters
        # n:: the ordinal number being requested
        # which_wday:: the weekday using Ruby time conventions, i.e. 0 => Sunday, 1 => Monday, ...
        
        # e.g. to obtain the 2nd Monday of the receivers year use
        #
        #   time.nth_wday_in_year(2, 1)
        def nth_wday_in_year(n, which_wday)
          if n > 0
            first_of_year = ::Date.new(self.year, 1, 1)
            first_in_year = first_of_year + (which_wday - first_of_year.wday + 7) % 7
            (first_in_year + (7*(n - 1))).to_ri_cal_property_value
          else
            december25 = ::Date.new(self.year, 12, 25)
            last_in_year = december25 + (which_wday - december25.wday + 7) % 7
            (last_in_year + (7 * (n + 1))).to_ri_cal_property_value
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
          first_of_month =::Date.new(self.year, self.month, 1)
          first_in_month = first_of_month + (which_wday - first_of_month.wday)
          first_in_month += 7 if first_in_month.month != first_of_month.month
          if n > 0
            (first_in_month + (7*(n - 1))).to_ri_cal_property_value
          else
            possible = first_in_month +  21
            possible += 7 while possible.month == first_in_month.month
            last_in_month = possible - 7
            (last_in_month - (7*(n.abs - 1))).to_ri_cal_property_value
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
      end
    end
  end
end