require File.expand_path(File.join(File.dirname(__FILE__), 'ventity'))

module Rfc2445
  class Vcalendar < Ventity

    attr_accessor :calscale_property, :method_property, :prodid_property, :version_property
    
    def self.entity_name
      "VCALENDAR"
    end

    def process_line(parser, line)
      case line[:name]
      when "CALSCALE"
        self.calscale_property = VTextProperty.new(line) 
      when "METHOD"
        self.method_property = VTextProperty.new(line) 
      when "PRODID"
        self.prodid_property = VTextProperty.new(line) 
      when "VERSION"
        self.version_property = VTextProperty.new(line)
      else 
        self.add_x_property(VTextProperty.new(line))
      end
    end
  end
end