require "#{File.dirname(__FILE__)}/time/conversions.rb"
require "#{File.dirname(__FILE__)}/time/tzid_access.rb"
require "#{File.dirname(__FILE__)}/time/week_day_predicates.rb"
require "#{File.dirname(__FILE__)}/time/calculations.rb"
#- ©2009 Rick DeNatale
#- All rights reserved. Refer to the file README.txt for the license
#
class Time #:nodoc:
  include RiCal::CoreExtensions::Time::WeekDayPredicates
  include RiCal::CoreExtensions::Time::Calculations  
  include RiCal::CoreExtensions::Time::Conversions
  include RiCal::CoreExtensions::Time::TzidAccess
end