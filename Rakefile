# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  load 'tasks/setup.rb'
end

ensure_in_path 'lib'
require 'rfc2445'

task :default => 'spec:run'

PROJ.name = 'rfc2445'
PROJ.authors = 'Rick DeNatale'
PROJ.email = 'rick.denatale@gmail.com'
PROJ.url = 'FIXME (project homepage)'
PROJ.version = Rfc2445::VERSION
PROJ.rubyforge.name = 'rfc2445'

PROJ.spec.opts << '--color'

# EOF
