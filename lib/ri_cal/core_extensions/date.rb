require "#{File.dirname(__FILE__)}/date/conversions.rb"
require "#{File.dirname(__FILE__)}/time/week_day_predicates.rb"
require "#{File.dirname(__FILE__)}/time/calculations.rb"
require 'date'
#- ©2009 Rick DeNatale
#- All rights reserved. Refer to the file README.txt for the license
#
class Date #:nodoc:
  include RiCal::CoreExtensions::Time::WeekDayPredicates
  include RiCal::CoreExtensions::Time::Calculations
  include RiCal::CoreExtensions::Date::Conversions
end
