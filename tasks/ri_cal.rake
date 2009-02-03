require 'active_support'

class VEntityUpdater
  def initialize(target)
    @target = target
    @name=File.basename(target).sub(".rb","")
    @indent = ""
    @property_map = {}
  end
  
  def property(name, options = {})
    options = {:type => 'Text', :ruby_name => name}.merge(options)
    if options[:type] == 'date_time_or_date'
      named_property(
        name,
        options[:ruby_name],
        options[:multi],
        options[:type],
        "DateTimeValue.from_separated_line(line)"
      )
    else
      named_property(name, options[:ruby_name], options[:multi], options[:type], "#{options[:type]}Value.new(line)")
    end
  end
  
  def indent(string)
    @outfile.puts("#{@indent}#{string}")
  end
  
  def named_property(name, ruby_name, multi, type, line_evaluator)
    ruby_name = ruby_name.tr("-", "_")
    property = "#{ruby_name.downcase}_property"
    @property_map[name.upcase] = :"#{property}_from_string"
    @outfile.puts
    if multi
      indent("def #{property}")
      indent("  @#{property} ||= []")
      indent("end")      
      @outfile.puts
      indent("def #{property}_from_string(line)")
      indent("  #{property} << #{line_evaluator}")
      indent("end")      
      @outfile.puts
      indent("def #{ruby_name.downcase}")
      indent("  #{property}.map {|prop| prop.value}")
      indent("end")
    else
      indent("attr_accessor :#{property}")
      @outfile.puts
      indent("def #{property}_from_string(line)")
      indent("  @#{property} = #{line_evaluator}")
      indent("end")      
      @outfile.puts
      indent("def #{ruby_name.downcase}")
      indent("  #{property}.value")
      indent("end")
    end
  end
  
  def mutually_exclusive *prop_names
    mutually_exclusive_properties << prop_names.map {|str| :"#{str}_property"}
  end
  
  def mutually_exclusive_properties
    @mutually_exclusive_properties ||= []
  end  

  def process_attr(line)
    if line.match(/^\s*(property|mutually_exclusive)\s/)
      instance_eval(line)
    else
      indent "\# #{line.sub(/^\s./,"")}"
    end
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
    target = File.join targetDir, File.basename(f)
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
  
  updateTask File.join(File.dirname(__FILE__), '..', '/entity_attributes', '*.rb'), :update_attributes

end  # namespace :rical
