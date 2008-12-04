require File.expand_path(File.join(File.dirname(__FILE__), 'v_text_property'))
require 'rubygems'
require 'activesupport'

module RiCal
  class Ventity

    def self.property_map
      @property_map ||= {}
    end
    
    prop_types = %w{text array integer duration cal_address uri date_list}
    prop_types.each do |type|
      type_class = "V#{type.camelize}Property"
      source = <<-SOURCEEND
      def self.#{type}_properties(*names)
        names.each do
          |name| property(name, #{type_class})
        end
      end
      
      class << self
        alias_method :#{type}_property, :#{type}_properties
      end
      SOURCEEND
      puts source
      instance_eval(source)
    end


    def self.date_time_or_date_properties(*names)
      names.each { |name| property(name, VDateTimeProperty) {|line| VDateTimeProperty.from_separated_line(line) } }
    end

    class << self
      alias_method :date_time_or_date_property, :date_time_or_date_properties
    end
        
    # By default, the ruby attribute name is derived from the RFC name
    def self.property(name, type = VTextProperty, &block)
      named_property(name, name, type, &block)
    end

    def self.named_property(name, ruby_name, type = VTextProperty, &block)
      ruby_name = ruby_name.tr("-", "_")
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
