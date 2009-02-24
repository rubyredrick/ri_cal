module RiCal
  class Component

    autoload :Timezone, 'lib/ri_cal/component/timezone.rb'
        
    def initialize(parent)
      @parent = parent
    end
    
    def self.from_parser(parser, parent)
      entity = self.new(parent)
      line = parser.next_separated_line
      while parser.still_in(entity_name, line)
        entity.process_line(parser, line)
        line = parser.next_separated_line
      end
      entity
    end
    
    def self.parse(io)
      Parser.new(io).parse
    end
    
    def self.parse_string(string)
      parse(StringIO.new(string))
    end
    
    def subcomponents
      @subcomponents ||= Hash.new {|h, k| h[k] = []}
    end
    
    # return an array of Alarm components within this component
    # Alarms may be contained within Events, and Todos
    def alarms
      subcomponents["VALARM"]
    end
    
    def add_subcomponent(parser, line)
      subcomponents[line[:value]] << parser.parse_one(line, self)
    end

    def process_line(parser, line)
      if line[:name] == "BEGIN"
        add_subcomponent(parser, line)
      else
        setter = self.class.property_parser[line[:name]]
        if setter
          send(setter, line)
        else 
          self.add_x_property(PropertyValue::Text.new(line), line[:name])
        end
      end
    end



    def x_properties
      @x_properties ||= {}
    end

    def add_x_property(prop, name)
      x_properties[name] = prop
    end
    
    def valid?
      !mutual_exclusion_violation
    end
    
    # return the value of a property if it exists
    # otherwise return nil
    def value_of_property(property)
      property ? property.value : nil
    end
  end
end

Dir[File.dirname(__FILE__) + "/component/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "lib/ri_cal/component/#{filename}"
end