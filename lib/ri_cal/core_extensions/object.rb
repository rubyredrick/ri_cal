require "#{File.dirname(__FILE__)}/object/conversions.rb"
class Object
  include RiCal::CoreExtensions::Object::Conversions
end