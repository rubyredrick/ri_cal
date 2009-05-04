#- ©2009 Rick DeNatale
#- All rights reserved

require "#{File.dirname(__FILE__)}/object/conversions.rb"
class Object #:nodoc:
  include RiCal::CoreExtensions::Object::Conversions
end