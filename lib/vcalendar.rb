class Rfc2445::Vcalendar
  
  def self.from_parser(parser)
    cal = self.new
    line = parser.next_separated_line
    while parser.still_in("VCALENDAR", line)
      
    end
    cal
  end
  
end