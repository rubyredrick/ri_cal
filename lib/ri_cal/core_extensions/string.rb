require "#{File.dirname(__FILE__)}/string/conversions.rb"
class String
  include RiCal::CoreExtensions::String::Conversions
end