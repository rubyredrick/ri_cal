require 'lib/ri_cal/core_extensions/time/conversions'
require 'lib/ri_cal/core_extensions/time/week_day_predicates'
class Time
  include RiCal::CoreExtensions::Time::WeekDayPredicates
  include RiCal::CoreExtensions::DateTime::Conversions
end