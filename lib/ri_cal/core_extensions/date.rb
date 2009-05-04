require "#{File.dirname(__FILE__)}/date/conversions.rb"
require "#{File.dirname(__FILE__)}/time/week_day_predicates.rb"
require "#{File.dirname(__FILE__)}/time/calculations.rb"
require 'date'

class Date #:nodoc:
  #- ©2009 Rick DeNatale
  #- All rights reserved. Refer to the file README.txt for the license
  #
  include RiCal::CoreExtensions::Time::WeekDayPredicates
  include RiCal::CoreExtensions::Time::Calculations
  include RiCal::CoreExtensions::Date::Conversions
end
