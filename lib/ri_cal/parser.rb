class RiCal::Parser
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
  
  def params_and_value(string)
    string = string.sub(/^:/,'')
    return ["", string] unless string.match(/^;/)
    segments = string.sub(';','').split(":")
    return ["", string] if segments.length < 2
    quote_count = 0
    gathering_params = true
    params = []
    values = []
    segments.each do |segment|
      if gathering_params
        params << segment
        quote_count += segment.count("\"")
        gathering_params = (1 == quote_count % 2)
      else
        values << segment
      end
    end
    [params.join(":"), values.join(":")]
  end
  
  def separate_line(string)
    match = string.match(/^([^;:]*)(.*)$/)
    name = match[1]
    params, value = *params_and_value(match[2])
    {
      :name => name,
      :params => parse_params(params),
      :value => value
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
    result = []
    while start_line = next_line
      result << parse_one(start_line)
    end
    result
  end
  
  def parse_one(start_line)
    first_line = separate_line(start_line)
    invalid unless first_line[:name] == "BEGIN"
    case first_line[:value]
    when "VCALENDAR"
      RiCal::Vcalendar.from_parser(self)
    when "VEVENT"
      RiCal::Vevent.from_parser(self)
    when "VTODO"
      RiCal::Vtodo.from_parser(self)
    when "VJOURNAL"
      RiCal::Vjournal.from_parser(self)
    when "VFREEBUSY"
      RiCal::Vfreebusy.from_parser(self)
    when "VTIMEZONE"
      RiCal::Vtimezone.from_parser(self)
    when "VALARM"
      RiCal::Valarm.from_parser(self)
    else
      invalid
    end
  end
end