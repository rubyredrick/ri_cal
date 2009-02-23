# module RiCal
#   module CoreExtensions
#   end
# end
Dir[File.dirname(__FILE__) + "/core_extensions/*.rb"].sort.each do |path|
  filename = File.basename(path)
  require "lib/ri_cal/core_extensions/#{filename}"
end