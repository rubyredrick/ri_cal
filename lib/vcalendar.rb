require File.expand_path(File.join(File.dirname(__FILE__), 'vtextproperty'))

module Rfc2445
  class Vcalendar
    
    attr_accessor :calscale_property, :method_property, :prodid_property, :version_property

    def self.from_parser(parser)
      cal = self.new
      line = parser.next_separated_line
      while parser.still_in("VCALENDAR", line)
        case line[:name]
        when "CALSCALE"
          cal.calscale_property = VTextProperty.new(line) 
        when "METHOD"
          cal.method_property = VTextProperty.new(line) 
        when "PRODID"
          cal.prodid_property = VTextProperty.new(line) 
        when "VERSION"
          cal.version_property = VTextProperty.new(line)
        else 
          cal.add_x_property(VTextProperty.new(line))
        end
        line = parser.next_separated_line
      end
      cal
    end
    
    def x_properties
      @x_properties ||= {}
    end
    
    def add_x_property(prop)
      x_properties[prop.name] = prop
    end
  end
end