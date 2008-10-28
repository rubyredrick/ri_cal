require File.expand_path(File.join(File.dirname(__FILE__), 'vtextproperty'))

module Rfc2445
  class Ventity


    def self.from_parser(parser)
      entity = self.new
      line = parser.next_separated_line
      while parser.still_in(entity_name, line)
        entity.process_line(parser, line)
        line = parser.next_separated_line
      end
      entity
    end
    
    
    def x_properties
      @x_properties ||= {}
    end
    
    def add_x_property(prop)
      x_properties[prop.name] = prop
    end
    
  end
end
