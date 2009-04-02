module RiCal
  class PropertyValue
    # RiCal::PropertyValue::Text represents an icalendar Text property value
    # which is defined in 
    # rfc 2445 section 4.3.11 pp 45-46
    class Text < PropertyValue
      def initialize(line)
        super
      end
      
      def ruby_value
        value.gsub(/\\[;,nN\\]/) {|match|
          case match[1,1]
          when /[,;\\]/
            match[1,1]
          when 'n', 'N'
            "\n"
          else
            match
          end
        }
      end
      
      def self.convert(string)
        ical_str = string.gsub(/\n|,|;/) {|match|
          if match == "\n"
            '\n'
          else
            "\\#{match}"
          end
          }
        self.new(:value => ical_str)
      end
    end
  end
end