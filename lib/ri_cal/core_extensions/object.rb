require "#{File.dirname(__FILE__)}/object/conversions.rb"
#- ©2009 Rick DeNatale
#- All rights reserved. Refer to the file README.txt for the license
#
class Object #:nodoc:
  include RiCal::CoreExtensions::Object::Conversions
end