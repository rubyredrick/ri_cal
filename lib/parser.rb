require 'lib/vcalendar'
require 'lib/valarm'
require 'lib/vevent'
require 'lib/vfreebusy'
require 'lib/vjournal'
require 'lib/vtimezone'
require 'lib/vtodo'

class Rfc2445::Parser
  def next_line
    result = nil
    begin
      result = buffer_or_line
      @buffer = nil
      while /^\s/ =~ buffer_or_line
        result = "#{result}#{@buffer.lstrip}"
        @buffer = nil
      end
    ensure
      return result
    end
  end
  
  def parse_params(string)
    if string
      string.split(";").inject({}) { |result, val|
        m = /^(.+)=(.+)$/.match(val)
        invalid unless m
        result[m[1]] = m[2]
        result 
        }
    else
      nil
    end
  end
  
  def separate_line(string)
    match = string.match(/^([^;:]*)(;([^:]*))?:(.*)$/)
    {
      :name => match[1],
      :params => parse_params(match[3]),
      :value => match[4]
    }
  end
     
  def next_separated_line
    line = buffer_or_line
    next_line ? separate_line(line) : nil
  end
  
  def buffer_or_line
    @buffer ||= @io.readline.chomp
  end

  def initialize(io = StringIO.new(""))
    @io = io
  end
  
  def self.parse(io = StringIO.new(""))
    new(io).parse
  end
  
  def invalid
    raise Exception.new("Invalid icalendar file")
  end
  
  def still_in(component, separated_line)
    invalid unless separated_line
    separated_line[:value] != component || separated_line[:name] != "END"
  end
  
  def parse
    first_line = separate_line(next_line)
    invalid unless first_line[:name] == "BEGIN"
    case first_line[:value]
    when "VCALENDAR"
      Rfc2445::Vcalendar.from_parser(self)
    when "VEVENT"
      Rfc2445::Vevent.from_parser(self)
    when "VTODO"
      Rfc2445::Vtodo.from_parser(self)
    when "VJOURNAL"
      Rfc2445::Vjournal.from_parser(self)
    when "VFREEBUSY"
      Rfc2445::Vfreebusy.from_parser(self)
    when "VTIMEZONE"
      Rfc2445::Vtimezone.from_parser(self)
    when "VALARM"
      Rfc2445::Valarm.from_parser(self)
    else
      invalid
    end
  end
end