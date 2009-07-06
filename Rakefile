#- ©2009 Rick DeNatale
#- All rights reserved. Refer to the file README.txt for the license
#
# %w[rubygems rake rake/clean fileutils newgem  rubigen].each { |f| require f }
#require File.dirname(__FILE__) + '/lib/ri_cal'

require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/ri_cal'

Hoe.plugin :newgem
Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec('ri_cal') do |p|
  p.developer('author=Rick DeNatale', 'rick.denatale@gmail.com')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.rubyforge_name       = 'ri-cal'
  p.readme_file = "README.txt"
  p.extra_dev_deps = [
    ['newgem', ">= #{::Newgem::VERSION}"],
    'ruby-prof'
  ]

  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake

# It looks like newgem is already defining these
# Rake::TaskManager.class_eval do
#   def remove_task(task_name)
#     @tasks.delete(task_name.to_s)
#   end
# end
#  
# def remove_task(task_name)
#   Rake.application.remove_task(task_name)
# end
 
# Override hoe's standard spec task
remove_task :spec

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => [:"spec:with_tzinfo_gem", :"spec:with_active_support"]
