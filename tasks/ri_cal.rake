require 'active_support'

class VEntityUpdater
  def initialize(name)
    @name = name
    @indent = ""
    @property_map = {}
  end
  
  def property(name, options = {})
    options = {:type => 'TextValue', :ruby_name => name}.merge(options)
    if options[:type] == 'date_time_or_date'
      named_property(
        name,
        options[:ruby_name],
        options[:multi],
        options[:type],
        "DateTimeValue.from_separated_line(line)"
      )
    else
      named_property(name, options[:ruby_name], options[:multi], options[:type], "#{options[:type]}.new(line)")
    end
  end
  
  def indent(string)
    @outfile.puts("#{@indent}#{string}")
  end
  
  def named_property(name, ruby_name, multi, type, line_evaluator)
    ruby_name = ruby_name.tr("-", "_")
    property = "#{ruby_name.downcase}_property"
    @property_map[name] = :"#{property}_from_string"
    @outfile.puts
    if multi
      indent("def #{property}")
      indent("  @#{property} ||= []")
      indent("end")      
      @outfile.puts
      indent("def #{property}_from_string(string)")
      indent("  @#{property} << #{line_evaluator}")
      indent("end")      
      @outfile.puts
      indent("def #{ruby_name.downcase}")
      indent("  #{property}.map {|prop| prop.value}")
      indent("end")
    else
      indent("attr_accessor :#{property}")
      @outfile.puts
      indent("def #{property}_from_string(string)")
      indent("  @#{property} = #{line_evaluator}")
      indent("end")      
      @outfile.puts
      indent("def #{ruby_name.downcase}")
      indent("  #{property}.value")
      indent("end")
    end
  end
  
  def mutually_exclusive *prop_names
    mutually_exclusive_properties << prop_names.map {|str| str.to_sym}
  end
  
  def mutually_exclusive_properties
    @mutually_exclusive_properties ||= []
  end  

  def process_attr(line)
    if line.match(/^\s*property\s/)
      instance_eval(line)
    else
      indent "\# #{line.sub(/^\s./,"")}"
    end
  end
  
  def generate_support_methods
    @outfile.puts
    indent("def self.property_parser")
    indent("  #{@property_setter.inspect}")
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
        indent("  return false if #{mutex_set.inspect}.inject(0) {|sum, prop| send(prop)}")
      end
      indent("  true")
    end
    indent "end"
  end
  
  def update
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
            File.foreach(File.join(File.dirname(__FILE__), '..', 'entity_attributes', "#{@name}.rb")) do |att_def|
              process_attr(att_def)
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
            state = :finish unless ruby_in_line =~ /^[\s]+$/
          end
        when :skip_old
          state = :finish if ruby_in_line =~ /#{post_tag}/
        when :finish
          ruby_out_file.puts(ruby_in_line)
         end
      end
      @outfile = nil            
    end
  end
end

def updateTask srcGlob, taskSymbol
  targetDir = File.join(File.dirname(__FILE__), ['../lib/ri_cal'])
  FileList[srcGlob].each do |f|
    target = File.join targetDir, File.basename(f)
    file target => [f] do |t|
      mv target, File.basename(f).sub(".rb",".rbold")
      VEntityUpdater.new(File.basename(f).sub(".rb","")).update
    end
    task taskSymbol => target
  end
end


namespace :rical do

  desc '(RE)Generate VEntity attributes'
  task :update_attributes do |t|
    # attr_dir = File.join(File.dirname(__FILE__), ['../entity_attributes/*.rb'])
    # puts "attr_dir = #{attr_dir}"
    # FileList.new(attr_dir).each do | attr_file |
    #   puts "file = #{attr_file.inspect}"
    # end
  end
  
  updateTask File.join(File.dirname(__FILE__), '..', '/entity_attributes', '*.rb'), :update_attributes

end  # namespace :rical
