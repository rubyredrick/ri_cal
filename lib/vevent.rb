require File.expand_path(File.join(File.dirname(__FILE__), 'ventity'))

module RiCal
  class Vevent < Ventity
    text_properties "attach", "comment", "description", "status", "summary"
    text_property "geo"
    #TODO: should parse alt-rep parameter
    text_property "location"
    named_property "class", "security_class"
    array_properties "categories", "resources"
    integer_property "priority"
    
   end
end