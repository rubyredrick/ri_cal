require File.expand_path(File.join(File.dirname(__FILE__), 'text_value'))

# code stolen from ActiveSupport Gem
unless  String.instance_methods.include?("camelize")
  class String
    def camelize
      self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  end
end

module RiCal
  class Ventity

    def self.property_map
      @property_map ||= {}
    end
    
    prop_types = %w{text array integer duration cal_address uri date_list recurrence_rule date_time}
    prop_types.each do |type|
      type_class = "#{type.camelize}Value"
      source_line = __LINE__ + 2
      source = <<-SOURCEEND
      def self.#{type}_properties(*names)
        names.each do
          |name| property(name, #{type_class})
        end
      end
      
      class << self
        alias_method :#{type}_property, :#{type}_properties
      end
      
      def self.#{type}_multi_properties(*names)
        names.each do
          |name| multi_property(name, #{type_class})
        end
      end
      
      class << self
        alias_method :#{type}_multi_property, :#{type}_multi_properties
      end
      SOURCEEND
      instance_eval(source, __FILE__, source_line)
    end


    def self.date_time_or_date_properties(*names)
      names.each { |name| property(name, DateTimeValue) {|line| DateTimeValue.from_separated_line(line) } }
    end

    class << self
      alias_method :date_time_or_date_property, :date_time_or_date_properties
    end
        
    # By default, the ruby attribute name is derived from the RFC name
    def self.property(name, type = VTextProperty, &block)
      named_property(name, name, false, type, &block)
    end

    def self.named_property(name, ruby_name, multi, type = TextValue, &block)
      ruby_name = ruby_name.tr("-", "_")
      property = "#{ruby_name.downcase}_property"
      attr_accessor property.to_sym

      unless instance_methods(false).include?(ruby_name.downcase)
        class_eval "def #{ruby_name.downcase};#{ruby_name.downcase}_property.value;end", __FILE__, __LINE__
      end

      if block_given?
        evaluator = lambda(&block)
      else
        evaluator = lambda {|line| type.new(line) }
      end
      if multi
        self.property_map[name.upcase] = lambda {|entity, line| 
          raise "multi-property called"
          entity.send("#{property}".to_sym) << evaluator.call(line) }
      else
        self.property_map[name.upcase] = lambda {|entity, line| entity.send("#{property}=".to_sym, evaluator.call(line)) }
      end
    end
    
    def self.single_named_property(name, ruby_name, type = TextValue, &block)
      named_property(name, ruby_name, false, type, &block)
    end

    def self.multi_property(name, type = VTextProperty, &block)
      named_property(name, name, true, type, &block)
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
    
    def self.parse(io)
      Parser.new(io).parse
    end
    
    def self.parse_string(string)
      parse(StringIO.new(string))
    end

    def process_line(parser, line)
      creator = self.class.property_map[line[:name]]
      if creator
        creator.call(self, line)
      else 
        self.add_x_property(TextValue.new(line))
      end
    rescue NoMethodError => ex
      raise "#{ex} raised for #{line.inspect}"
    end



    def x_properties
      @x_properties ||= {}
    end

    def add_x_property(prop)
      x_properties[prop.name] = prop
    end

  end
end
