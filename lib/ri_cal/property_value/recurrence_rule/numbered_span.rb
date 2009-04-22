module RiCal
  class PropertyValue
    class RecurrenceRule < PropertyValue

      class NumberedSpan # :nodoc:
        attr_reader :source
        def initialize(source, rule = nil)
          @source = source
          @rule = rule
        end

        def valid?
          (1..last).include?(source) || (-last..-1).include?(source)
        end

        def  ==(another)
          self.class == another.class && source == another.source
        end

        def to_s
          source.to_s
        end
        
        def ordinal
          @source
        end
      end
    end
  end
end