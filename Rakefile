#- ©2009 Rick DeNatale
#- All rights reserved. Refer to the file README.txt for the license
#
%w[rubygems rake rake/clean fileutils newgem  rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/ri_cal'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('ri_cal', RiCal::VERSION) do |p|
  p.developer('author=Rick DeNatale', 'rick.denatale@gmail.com')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  # p.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  p.rubyforge_name       = 'ri-cal'
  # p.extra_deps         = [
  #   ['tzinfo','>= 2.0.2'],
  # ]
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
Dir['tasks/**/*.rake'].each { |t| load t }

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end
 
def remove_task(task_name)
  Rake.application.remove_task(task_name)
end
 
# Override existing test task to prevent integrations
# from being run unless specifically asked for
remove_task :test
task :test do
end

task :default => [:"spec:with_tzinfo_gem", :"spec:with_active_support"]
