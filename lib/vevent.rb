require File.expand_path(File.join(File.dirname(__FILE__), 'ventity'))

module Rfc2445
  class Vevent < Ventity
    
    attr_accessor :attach_property, :categories_property
    
    def self.entity_name
      "VEVENT"
    end



    def process_line(parser, line)
      case line[:name]
      when "ATTACH"
        self.attach_property = VTextProperty.new(line)
        # TO-DO - should be an array property
      when "CATEGORIES"
        self.categories_property = VTextProperty.new(line) 
      else 
        self.add_x_property(VTextProperty.new(line))
      end
    end

  end
end