require 'active_support'
require 'yaml'

class VEntityUpdater
  def initialize(target)
    @target = target
    @name=File.basename(target).sub(".rb","")
    @indent = ""
    @property_map = {}
  end
  
  def property(prop_def_hash)
    name = prop_def_hash.keys[0]
    options = {'type' => 'Text', 'ruby_name' => name}.merge(prop_def_hash[name] || {})
    named_property(name, options)
  end
  
  def indent(string)
    @outfile.puts("#{@indent}#{string}")
  end
  
  def comment(string)
    indent("\# #{string}")
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
  
  def named_property(name, options)
    puts "options=#{options.inspect}"
    ruby_name = options['ruby_name']
    multi = options['multi']
    type = options['type']
    rfc_ref = options['rfc_ref']
    conflicts = options['conflicts_with']
    if conflicts
      mutually_exclusive(name, *conflicts)
    end
    puts "named_property(#{name.inspect}, #{ruby_name.inspect}, #{multi.inspect}, #{type.inspect}, #{rfc_ref.inspect})"
    ruby_name = ruby_name.tr("-", "_")
    property = "#{ruby_name.downcase}_property"
    @property_map[name.upcase] = :"#{property}_from_string"
    if type == 'date_time_or_date'
      line_evaluator = "DateTimeValue.from_separated_line(line)"
      type_class = "DateTimeValue"
    else
      type_class = "#{type}Value"
      line_evaluator = "#{type_class}.new(line)"
    end
    blank_line
    if multi
      comment("return the value of the #{name.upcase} property")
      comment("which will be an array of instances of #{describe_type(type)}")
      comment("see RFC 2445 #{rfc_ref}") if rfc_ref
      indent("def #{ruby_name.downcase}")
      indent("  #{property}.map {|prop| prop.value}")
      indent("end")
      blank_line
      comment("set the #{name.upcase} property")
      comment("one or more instances of #{describe_type(type)} may be passed to this method")
      indent("def #{ruby_name.downcase}=(*ruby_values)")
      indent("  #{property}= ruby_values.map {|val| #{type_class}.convert(val)}")
      indent("end")
      blank_line
      no_doc("def #{property}")
      indent("  @#{property} ||= []")
      indent("end")      
      blank_line
      no_doc("def #{property}_from_string(line)")
      indent("  #{property} << #{line_evaluator}")
      indent("end")      
    else
      comment("return the value of the #{name.upcase} property")
      comment("which will be an instance of #{describe_type(type)}")
      comment("see RFC 2445 #{rfc_ref}") if rfc_ref
      indent("def #{ruby_name.downcase}")
      indent("  #{property}.value")
      indent("end")
      blank_line
      comment("set the #{name.upcase} property")
      indent("def #{ruby_name.downcase}=(*ruby_values)")
      indent("  #{property}= #{type_class}.convert(ruby_val)")
      indent("end")
      blank_line
      indent("attr_accessor :#{property}")
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
    @outfile.puts
    indent("def self.property_parser")
    indent("  #{@property_map.inspect}")
    indent("end")
    @outfile.puts
    indent("def mutual_exclusion_violation")
    if mutually_exclusive_properties.empty?
      indent("  false")
    else
      # self.class.mutually_exclusive_properties.each do |mutex_set|
      #   return false if mutex_set.inject(0) { |sum, prop| send(prop.to_sym) ? sum + 1 : sum } > 1
      # end
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
  FileList[srcGlob].each do |f|
    target = File.join targetDir, File.basename(f).sub(".yml", ".rb")
    file target => [f] do |t|
      VEntityUpdater.new(target).update
    end
    task taskSymbol => target
  end
end


namespace :rical do

  desc '(RE)Generate VEntity attributes'
  task :update_attributes do |t|
  end
  
  updateTask File.join(File.dirname(__FILE__), '..', '/entity_attributes', '*.yml'), :update_attributes

end  # namespace :rical
