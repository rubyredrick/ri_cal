module RiCal

  # :stopdoc:
  VERSION = '0.0.1'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end

  # Utility method used to rquire all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '**', '*.rb'))
    Dir.glob(search_me).sort.each {|rb| require rb}
  end
  
  # :startdoc:
  
  # Parse an io stream and return an array of iCalendar entities.
  # Normally this will be an array of RiCal::Calendar instances
  def self.parse(io)
    Parser.new(io).parse
  end
  
  # Parse a string and return an array of iCalendar entities.
  # see RiCal.parse
  def self.parse_string(string)
    parse(StringIO.new(string))
  end
  

end  # module RiCal

class RiCal::Component;end
class RiCal::Timezone < RiCal::Component;end
class RiCal::TimezonePeriod < RiCal::Component;end
module RiCal::OccurrenceEnumerator;end

require File.join(File.dirname(__FILE__), *%w[ri_cal property_value])
require File.join(File.dirname(__FILE__), *%w[ri_cal component])
RiCal.require_all_libs_relative_to(__FILE__)

# EOF
