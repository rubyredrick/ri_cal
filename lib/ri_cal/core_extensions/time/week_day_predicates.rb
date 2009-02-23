module RiCal
  module CoreExtensions
    module Time
      module WeekDayPredicates
        def nth_wday_in_year?(n, which_wday)
          if n > 0
            first_of_year = ::Date.new(self.year, 1, 1)
            first_in_year = first_of_year + (which_wday - first_of_year.wday + 7) % 7
            target = first_in_year + (7*(n - 1))
          else
            december25 = ::Date.new(self.year, 12, 25)
            last_in_year = december25 + (which_wday - december25.wday + 7) % 7
            target = last_in_year + (7 * (n + 1))
          end
          [self.year, self.mon, self.day] == [target.year, target.mon, target.day]
        end

        def nth_wday_in_month?(n, which_wday)
          first_of_month =::Date.new(self.year, self.month, 1)
          first_in_month = first_of_month + (which_wday - first_of_month.wday)
          first_in_month += 7 if first_in_month.month != first_of_month.month
          if n > 0
            target = first_in_month + (7*(n - 1))
          else
            possible = first_in_month +  21
            possible += 7 while possible.month == first_in_month.month
            last_in_month = possible - 7
            target = last_in_month - (7*(n.abs - 1))
          end
          [self.year, self.mon, self.day] == [target.year, target.mon, target.day]
        end      
      end
    end
  end
end