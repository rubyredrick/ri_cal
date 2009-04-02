class RiCal::Parser # :nodoc:
  def next_line
    result = nil
    begin
      result = buffer_or_line
      @buffer = nil
      while /^\s/ =~ buffer_or_line
        result = "#{result}#{@buffer[1..-1]}"
        @buffer = nil
      end
    rescue EOFError
      return nil
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
    line = next_line
    line ? separate_line(line) : nil
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
      @parent_stack = []
      result << parse_one(start_line, nil)
    end
    result
  end

  # TODO: Need to parse non-standard component types (iana-tokey or x-name)
  def parse_one(start, parent_component)

    @parent_stack << parent_component
    if Hash === start
      first_line = start
    else
      first_line = separate_line(start)
    end
    invalid unless first_line[:name] == "BEGIN"
    result = case first_line[:value]
    when "VCALENDAR"
      RiCal::Component::Calendar.from_parser(self, parent_component)
    when "VEVENT"
      RiCal::Component::Event.from_parser(self, parent_component)
    when "VTODO"
      RiCal::Component::Todo.from_parser(self, parent_component)
    when "VJOURNAL"
      RiCal::Component::Journal.from_parser(self, parent_component)
    when "VFREEBUSY"
      RiCal::Component::Freebusy.from_parser(self, parent_component)
    when "VTIMEZONE"
      RiCal::Component::Timezone.from_parser(self, parent_component)
    when "VALARM"
      RiCal::Component::Alarm.from_parser(self, parent_component)
    when "DAYLIGHT"
      RiCal::Component::Timezone::DaylightPeriod.from_parser(self, parent_component)
    when "STANDARD"
      RiCal::Component::Timezone::StandardPeriod.from_parser(self, parent_component)
    else
      invalid
    end
    @parent_stack.pop
    result
  end
end