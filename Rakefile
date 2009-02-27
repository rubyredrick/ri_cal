# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

gem 'rdoc', ">2"
load 'rdoc'


begin
  require 'bones'
  Bones.setup
rescue LoadError
  load 'tasks/setup.rb'
end

ensure_in_path 'lib'
require 'ri_cal'

task :default => 'spec:run'

PROJ.name = 'ri_cal'
PROJ.authors = 'Rick DeNatale'
PROJ.email = 'rick.denatale@gmail.com'
PROJ.url = 'FIXME (project homepage)'
PROJ.version = RiCal::VERSION
PROJ.rubyforge.name = 'ri_cal'
PROJ.ruby_opts = []

PROJ.spec.opts << '--color'
PROJ.spec.opts << '--format nested'
PROJ.rdoc.opts = ['-SHN','-f', 'darkfish' ]

require 'metric_fu'

# EOF
