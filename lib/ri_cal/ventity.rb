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
    
    # def self.mutually_exclusive *prop_names
    #   mutually_exclusive_properties << prop_names
    # end
    # 
    # def self.mutually_exclusive_properties
    #   @mutually_exclusive_properties ||= []
    # end
    # 
    # def self.property_map
    #   @property_map ||= {}
    # end
    
    # prop_types = %w{text array integer duration cal_address uri date_list recurrence_rule date_time}
    # prop_types.each do |type|
    #   type_class = "#{type.camelize}Value"
    #   source_line = __LINE__ + 2
    #   source = <<-SOURCEEND
    #   def self.#{type}_properties(*names)
    #     names.each do
    #       |name| property(name, #{type_class})
    #     end
    #   end
    #   
    #   class << self
    #     alias_method :#{type}_property, :#{type}_properties
    #   end
    #   
    #   def self.#{type}_multi_properties(*names)
    #     names.each do
    #       |name| multi_property(name, #{type_class})
    #     end
    #   end
    #   
    #   class << self
    #     alias_method :#{type}_multi_property, :#{type}_multi_properties
    #   end
    #   SOURCEEND
    #   instance_eval(source, __FILE__, source_line)
    # end

    # def self.property(name, options = {})
    #   options = {:type => TextValue, :ruby_name => name}.merge(options)
    #   if options[:type] == 'date_time_or_date'
    #     named_property(
    #       name,
    #       options[:ruby_name],
    #       options[:multi],
    #       options[:type]
    #     ) {|line| DateTimeValue.from_separated_line(line) }
    #   else
    #     named_property(name, options[:ruby_name], options[:multi], options[:type])
    #   end
    # end
    # 
    # def self.named_property(name, ruby_name, multi, type = TextValue, &block)
    #   ruby_name = ruby_name.tr("-", "_")
    #   property = "#{ruby_name.downcase}_property"
    #   if multi
    #     class_eval "def #{property};@#{property} ||= [];end", __FILE__, __LINE__
    #   else
    #     attr_accessor property.to_sym
    #   end
    # 
    #   unless instance_methods(false).include?(ruby_name.downcase)
    #     if multi
    #       class_eval "def #{ruby_name.downcase};#{ruby_name.downcase}_property.map {|prop| prop.value};end", __FILE__, __LINE__
    #     else
    #       class_eval "def #{ruby_name.downcase};#{ruby_name.downcase}_property.value;end", __FILE__, __LINE__
    #     end
    #   end
    # 
    #   if block_given?
    #     evaluator = lambda(&block)
    #   else
    #     evaluator = lambda {|line| type.new(line) }
    #   end
    #   if multi
    #     self.property_map[name.upcase] = lambda {|entity, line| 
    #       entity.send("#{property}".to_sym) << evaluator.call(line) }
    #   else
    #     self.property_map[name.upcase] = lambda {|entity, line| entity.send("#{property}=".to_sym, evaluator.call(line)) }
    #   end
    # end

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
      setter = self.class.property_parser[line[:name]]
      if setter
        send(setter, line)
      else 
        self.add_x_property(TextValue.new(line))
      end
    end



    def x_properties
      @x_properties ||= {}
    end

    def add_x_property(prop)
      x_properties[prop.name] = prop
    end
    
    def valid?
      !mutual_exclusion_violation
    end

  end
end
