module RiCal
  class PropertyValue
    class OccurrenceList < Array
      class Enumerator

        attr_accessor :default_duration, :occurrence_list

        # TODO: the component parameter should always be the parent
        def initialize(occurrences, component)
          self.occurrence_list = occurrences
          self.default_duration = component.default_duration
          @index = 0
        end

        def next_occurrence
          if @index < occurrence_list.length
            result = occurrence_list[@index].occurrence_hash(default_duration)
            @index += 1
            result
          else
            nil
          end
        end
      end

      def value=(string)
        super
        case params[:value]
        when 'DATE-TIME', nil
          @elements = @value.map {|string| PropertyValue::DateTime.new(:value => string)}
        when 'DATE'
          @elements = @value.map {|string| PropertyValue::Date.new(:value => string)}
        when 'PERIOD'
        end
      end
    end
    
    def enumerator(component)
      OccurrenceList::Enumerator.new(@elements, component)
    end
  end
end