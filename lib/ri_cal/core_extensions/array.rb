require "#{File.dirname(__FILE__)}/array/conversions.rb"
class Array
  include RiCal::CoreExtensions::Array::Conversions
end