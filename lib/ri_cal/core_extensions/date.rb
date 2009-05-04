#- ©2009 Rick DeNatale
#- All rights reserved

require "#{File.dirname(__FILE__)}/date/conversions.rb"
require "#{File.dirname(__FILE__)}/time/week_day_predicates.rb"
require "#{File.dirname(__FILE__)}/time/calculations.rb"
require 'date'
class Date #:nodoc:
  include RiCal::CoreExtensions::Time::WeekDayPredicates
  include RiCal::CoreExtensions::Time::Calculations
  include RiCal::CoreExtensions::Date::Conversions
end
