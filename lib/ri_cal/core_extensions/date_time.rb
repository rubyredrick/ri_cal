#- ©2009 Rick DeNatale
#- All rights reserved

require "#{File.dirname(__FILE__)}/date_time/conversions.rb"
require "#{File.dirname(__FILE__)}/time/week_day_predicates.rb"
require "#{File.dirname(__FILE__)}/time/calculations.rb"
require 'date'
class DateTime #:nodoc:
  include RiCal::CoreExtensions::Time::WeekDayPredicates
  include RiCal::CoreExtensions::Time::Calculations
  include RiCal::CoreExtensions::DateTime::Conversions
end