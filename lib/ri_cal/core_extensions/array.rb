#- ©2009 Rick DeNatale
#- All rights reserved

require "#{File.dirname(__FILE__)}/array/conversions.rb"
class Array #:nodoc:
  include RiCal::CoreExtensions::Array::Conversions
end