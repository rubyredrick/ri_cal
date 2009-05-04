#- ©2009 Rick DeNatale
#- All rights reserved

require "#{File.dirname(__FILE__)}/string/conversions.rb"
class String #:nodoc:
  include RiCal::CoreExtensions::String::Conversions
end