require File.expand_path(File.join(File.dirname(__FILE__), 'ventity'))

module Rfc2445
  class Vevent < Ventity
    text_property "attach"
    array_property "categories"
    
   end
end