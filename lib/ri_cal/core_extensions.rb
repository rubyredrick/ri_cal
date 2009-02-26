# module RiCal
#   module CoreExtensions
#   end
# end
Dir[File.dirname(__FILE__) + "/core_extensions/*.rb"].sort.each do |path|
  require path
end