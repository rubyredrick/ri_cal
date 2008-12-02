require File.expand_path(File.join(File.dirname(__FILE__), 'v_text_property'))

module RiCal
  class Ventity

    def self.property_map
      @property_map ||= {}
    end

    def self.text_properties(*names)
      names.each do |name|
        property(name)
      end
    end

    def self.array_properties(*names)
      names.each do |name|
        property(name, VArrayProperty)
      end
    end

    def self.integer_properties(*names)
      names.each do |name|
        property(name, VIntegerProperty)
      end
    end

    class << self
      alias_method :text_property, :text_properties
      alias_method :array_property, :array_properties
      alias_method :integer_property, :integer_properties
    end
        
    # By default, the ruby attribute name is derived from the RFC name
    def self.property(name, type = VTextProperty, &block)
      named_property(name, name, type, &block)
    end

    def self.named_property(name, ruby_name, type = VTextProperty, &block)
      property = "#{ruby_name.downcase}_property"
      attr_accessor property.to_sym

      unless instance_methods(false).include?(ruby_name.downcase)
        class_eval "def #{ruby_name.downcase};#{ruby_name.downcase}_property.value;end"
      end

      if block_given?
        evaluator = lambda(&block)
      else
        evaluator = lambda {|line| type.new(line) }
      end
      self.property_map[name.upcase] = lambda {|entity, line| entity.send("#{property}=".to_sym, evaluator.call(line)) }
    end

    def self.entity_name
      @entity_name ||= to_s.split("::").last.upcase
    end

    def self.from_parser(parser)
      entity = self.new
      line = parser.next_separated_line
      while parser.still_in(entity_name, line)
        entity.process_line(parser, line)
        line = parser.next_separated_line
      end
      entity
    end

    def process_line(parser, line)
      creator = self.class.property_map[line[:name]]
      if creator
        creator.call(self, line)
      else 
        self.add_x_property(VTextProperty.new(line))
      end
    end



    def x_properties
      @x_properties ||= {}
    end

    def add_x_property(prop)
      x_properties[prop.name] = prop
    end

  end
end
