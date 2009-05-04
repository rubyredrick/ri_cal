#- ©2009 Rick DeNatale
#- All rights reserved. Refer to the file README.txt for the license
#
Dir[File.dirname(__FILE__) + "/core_extensions/*.rb"].sort.each do |path|
  require path
end