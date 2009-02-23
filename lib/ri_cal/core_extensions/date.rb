require 'lib/ri_cal/core_extensions/date/conversions'
require 'lib/ri_cal/core_extensions/time/week_day_predicates'
require 'date'
class Date
  include RiCal::CoreExtensions::Time::WeekDayPredicates
  include RiCal::CoreExtensions::Date::Conversions
end
