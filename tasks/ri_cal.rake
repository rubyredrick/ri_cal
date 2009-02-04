require 'active_support'
require 'yaml'

class VEntityUpdater
  def initialize(target, defs_file)
    @target = target
    @name=File.basename(target).sub(".rb","")
    @indent = ""
    @property_map = {}
    @property_defs = YAML.load_file(defs_file)
  end
  
  def property(prop_name_or_hash)
    if Hash === prop_name_or_hash
      name = prop_name_or_hash.keys[0]
      override_options = prop_name_or_hash[name] || {}
    else
      name = prop_name_or_hash
      override_options = {}
    end
    standard_options = @property_defs[name]
    unless standard_options
      puts "**** WARNING, no definition found for property #{name}"
      standard_options = {}
    end
    options = {'type' => 'Text', 'ruby_name' => name}.merge(standard_options).merge(override_options)
    named_property(name, options)
  end
  
  def indent(string)
    @outfile.puts("#{@indent}#{string}")
  end
  
  def comment(*strings)
    strings.each do |string|
      indent("\# #{string}")
    end
  end
  
  def no_doc(string)
    indent("#{string} \# :nodoc:")
  end
  
  def blank_line
    @outfile.puts
  end
  
  def describe_type(type)
    case type
    when 'date_time_or_date'
      "either DateTime or Date"
    when 'Text'
      'String'
    else
      type
    end
  end
  
  def describe_property(type)
    case type
    when 'date_time_or_date'
      "either RiCal::DateTimeValue or RiCall::DateValue"
    else
      "RiCal::#{type}Value"
    end
  end

  def type_class(type)
    if type == 'date_time_or_date'
       "DateTimeValue"
     else
       "#{type}Value"
     end
   end
    
  def cast_value(ruby_val, type)
    "#{type_class(type)}.convert(#{ruby_val.inspect})"
  end
  
  def lazy_init_var(var, options)
    const_val = options["constant_value"]
    default_val = options["default_value"]
    if options["multi"]
      puts("*** Warning default_value of #{default_val} for multi-value property #{name} ignored") if default_val
      puts("*** Warning const_value of #{const_val} for multi-value property #{name} ignored") if const_val
      if var
        "@#{var} ||= []"
      else
        "[]"
      end     
    else
      puts("*** Warning default_value of #{default_val} for property #{name} with constant_value of #{const_val}") if const_val && default_val
      init_val =  const_val || default_val
      if init_val
        if var
          "@#{var} ||= #{cast_value(init_val, options["type"])}"
        else
          init_val.inspect
        end
      else
        "@#{var}"
      end
    end
  end
  
  def named_property(name, options)
    puts options.inspect if name == "calscale"
    ruby_name = options['ruby_name']
    multi = options['multi']
    type = options['type']
    rfc_ref = options['rfc_ref']
    conflicts = options['conflicts_with']
    options.keys.each do |opt_key|
      unless %w{
        ruby_name 
        type 
        multi 
        rfc_ref 
        conflicts_with 
        purpose 
        constant_value
        default_value
        }.include?(opt_key)
        puts "**** WARNING: unprocessed option key #{opt_key} for property #{name}"
      end
    end
    if conflicts
      mutually_exclusive(name, *conflicts)
    end
    ruby_name = ruby_name.tr("-", "_")
    property = "#{name.tr("-", "_").downcase}_property"
    @property_map[name.upcase] = :"#{property}_from_string"
    if type == 'date_time_or_date'
      line_evaluator = "DateTimeValue.from_separated_line(line)"
    else
      line_evaluator = "#{type_class(type)}.new(line)"
    end
    blank_line
    if multi
      comment(
        "return the the #{name.upcase} property",
        "which will be an array of instances of #{describe_property(type)}"
      )
      comment("", "[purpose (from RFC 2445)]", options["purpose"]) if options["purpose"]
      comment("", "see RFC 2445 #{rfc_ref}") if rfc_ref
      indent("def #{property}")     
      indent("  #{lazy_init_var(property,options)}")
      indent("end")
      unless (options["constant_value"])      
        blank_line
        comment("set the the #{name.upcase} property")
        comment("one or more instances of #{describe_property(type)} may be passed to this method")
        indent("def #{property}=(*property_values)")
        indent("  #{property}= property_values")
        indent("end")
        blank_line
        comment("set the value of the #{name.upcase} property")
        comment("one or more instances of #{describe_type(type)} may be passed to this method")
        indent("def #{ruby_name.downcase}=(*ruby_values)")
        indent("  @#{property} = ruby_values.map {|val| #{type_class(type)}.convert(val)}")
        indent("end")
      end
      blank_line
      comment("return the value of the #{name.upcase} property")
      comment("which will be an array of instances of #{describe_type(type)}")
      indent("def #{ruby_name.downcase}")
      indent("  #{property}.map {|prop| value_of_property(prop)}")
      indent("end")
      blank_line
    no_doc("def #{property}_from_string(line)")
      indent("  #{property} << #{line_evaluator}")
      indent("end")      
    else
      comment(
        "return the the #{name.upcase} property",
        "which will be an instances of #{describe_property(type)}"
      )
      comment("", "[purpose (from RFC 2445)]", options["purpose"]) if options["purpose"]
      comment("", "see RFC 2445 #{rfc_ref}") if rfc_ref
      indent("def #{property}")
      indent("  #{lazy_init_var(property,options)}")
      indent("end")      
      unless (options["constant_value"])      
        blank_line
        comment("set the #{name.upcase} property")
        comment("property value should be an instance of #{describe_property(type)}")
        indent("def #{property}=(property_value)")
        indent("  @#{property} = property_value")
        if conflicts
          conflicts.each do |conflict|
            indent("  @#{conflict}_property = nil")
          end
        end           
        indent("end")
        blank_line
        comment("set the value of the #{name.upcase} property")
        indent("def #{ruby_name.downcase}=(ruby_value)")
        indent("  self.#{property}= #{type_class(type)}.convert(ruby_value)")
        indent("end")
      end
      blank_line
      comment("return the value of the #{name.upcase} property")
      comment("which will be an instance of #{describe_type(type)}")
      indent("def #{ruby_name.downcase}")
      indent("  value_of_property(#{property})")
      indent("end")
      blank_line
      no_doc("def #{property}_from_string(line)")
      indent("  @#{property} = #{line_evaluator}")
      indent("end")      
      @outfile.puts
    end
  end

  def mutually_exclusive *prop_names
    exclusives = prop_names.map {|str| :"#{str}_property"}.sort {|a, b| a.to_s <=> b.to_s}
    unless mutually_exclusive_properties.include?(exclusives)
      mutually_exclusive_properties << prop_names.map {|str| :"#{str}_property"}
    end
  end
  
  def mutually_exclusive_properties
    @mutually_exclusive_properties ||= []
  end  

  def generate_support_methods
    blank_line
    indent("def self.property_parser")
    indent("  #{@property_map.inspect}")
    indent("end")
    blank_line
    indent("def mutual_exclusion_violation")
    if mutually_exclusive_properties.empty?
      indent("  false")
    else
      mutually_exclusive_properties.each do |mutex_set|
        indent("  return true if #{mutex_set.inspect}.inject(0) {|sum, prop| send(prop) ? sum + 1 : sum} > 1")
      end
      indent("  false")
    end
    indent "end"
  end
  
  def update
    FileUtils.mv @target, @target.sub(".rb",".rbold")    
    pre_tag = "\# BEGIN GENERATED ATTRIBUTE CODE"
    post_tag = "\# END GENERATED ATTRIBUTE CODE"
    state = :find_class_def
    File.open(File.join(File.dirname(__FILE__), '..', 'lib', 'ri_cal',  "#{@name}.rb"), 'w') do |ruby_out_file|
      @outfile = ruby_out_file
      File.foreach(File.join(File.dirname(__FILE__), '..', 'lib', 'ri_cal', "#{@name}.rbold")) do |ruby_in_line|
        case state
        when :find_class_def
          if ruby_in_line =~ /class #{@name.camelize}/
            state = :generate
            @indent = "#{ruby_in_line.match(/^\s*/)[0]}  "
            ruby_out_file.puts(ruby_in_line)
            indent(pre_tag)
            YAML.load_file(File.join(File.dirname(__FILE__), '..', 'entity_attributes', "#{@name}.yml")).each do |att_def|
              property(att_def)
            end
            generate_support_methods
            indent(post_tag)
            state = :found_class_def
          else
            ruby_out_file.puts(ruby_in_line)
          end
        when :found_class_def
          if ruby_in_line =~ /#{pre_tag}/
            state = :skip_old
          else
            ruby_out_file.puts(ruby_in_line)
            state = :finish unless ruby_in_line =~ /^[\s]+$/
          end
        when :skip_old
          if ruby_in_line =~ /#{post_tag}/
            state = :finish
          end
        when :finish
          ruby_out_file.puts(ruby_in_line)
        end
      end
      @outfile = nil            
    end
    FileUtils.rm @target.sub(".rb",".rbold")    
  end
end

def updateTask srcGlob, taskSymbol
  targetDir = File.join(File.dirname(__FILE__), '..', 'lib', 'ri_cal')
  defsFile = File.join(File.dirname(__FILE__), '..', 'entity_attributes', 'component_property_defs.yml')
  FileList[srcGlob].each do |f|
    unless f == defsFile
      target = File.join targetDir, File.basename(f).sub(".yml", ".rb")
      file target => [f, defsFile, __FILE__] do |t|
        VEntityUpdater.new(target, defsFile).update
      end
      task taskSymbol => target
    end
  end
end


namespace :rical do

  desc '(RE)Generate VEntity attributes'
  task :gen_entities do |t|
  end
  
  updateTask File.join(File.dirname(__FILE__), '..', '/entity_attributes', '*.yml'), :update_attributes

end  # namespace :rical
