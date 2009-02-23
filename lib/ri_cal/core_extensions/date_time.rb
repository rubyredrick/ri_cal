require 'lib/ri_cal/core_extensions/date_time/conversions'
require 'lib/ri_cal/core_extensions/time/week_day_predicates'
require 'lib/ri_cal/core_extensions/time/calculations'
require 'date'
class DateTime
  include RiCal::CoreExtensions::Time::WeekDayPredicates
  include RiCal::CoreExtensions::Time::Calculations
  include RiCal::CoreExtensions::DateTime::Conversions
end