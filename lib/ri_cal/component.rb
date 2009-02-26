module RiCal
  class Component

    autoload :Timezone, "#{File.dirname(__FILE__)}/component/timezone.rb"
        
    def initialize(parent)
      @parent = parent
    end
    
    def self.from_parser(parser, parent) # :nodoc:
      entity = self.new(parent)
      line = parser.next_separated_line
      while parser.still_in(entity_name, line)
        entity.process_line(parser, line)
        line = parser.next_separated_line
      end
      entity
    end
    
    def self.parse(io) # :nodoc:
      Parser.new(io).parse
    end
    
    def self.parse_string(string) # :nodoc:
      parse(StringIO.new(string))
    end
    
    def subcomponents # :nodoc:
      @subcomponents ||= Hash.new {|h, k| h[k] = []}
    end
    
    # return an array of Alarm components within this component
    # Alarms may be contained within Events, and Todos
    def alarms
      subcomponents["VALARM"]
    end
    
    def add_subcomponent(parser, line) # :nodoc:
      subcomponents[line[:value]] << parser.parse_one(line, self)
    end

    def process_line(parser, line) # :nodoc:
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

    # return a hash of any extended properties, (i.e. those with a property name starting with "X-" 
    # representing an extension to the RFC 2445 specification)
    def x_properties
      @x_properties ||= {}
    end

    def add_x_property(prop, name) # :nodoc:
      x_properties[name] = prop
    end
    
    # Predicate to determine if the component is valid according to RFC 2445
    def valid?
      !mutual_exclusion_violation
    end
    
    def initialize_copy(original) # :nodoc:
    end
    
    def prop_string(prop_name, *properties) # :nodoc:
      properties = properties.flatten.compact
      if properties && !properties.empty?
        properties.map {|prop| "#{prop_name}#{prop.to_s}"}.join("\n")
      else
        nil
      end
    end
    
  end
end

Dir[File.dirname(__FILE__) + "/component/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require path
end