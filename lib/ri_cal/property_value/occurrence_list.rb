module RiCal
  class PropertyValue
    # OccurrenceList is used to represent the value of an RDATE or EXDATE property.
    #- ©2009 Rick DeNatale
    #- All rights reserved. Refer to the file README.txt for the license
    #
    class OccurrenceList < Array
      attr_accessor :tzid
      
      class Enumerator # :nodoc:

        attr_accessor :default_duration, :occurrence_list

        # TODO: the component parameter should always be the parent
        def initialize(occurrences, component) # :nodoc:
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
      
      def initialize(timezone_finder, options={}) # :nodoc:
        super
        validate_elements
        rputs "source_elements are #{@source_elements.inspect}"
      end
      
      def self.convert(timezone_finder, ruby_object) # :nodoc:
        if ::Array === ruby_object
          new(timezone_finder, :source_elements => ruby_object )
        else
          new(timezone_finder, :source_elements => [ruby_object] )
        end
      end
      
      def values_to_elements(values)
        values.map {|val| PropertyValue.date_or_date_time_or_period(self, :value => val)}
      end
      
      def validate_elements
        if @source_elements
          @elements = values_to_elements(@source_elements)
          @value = @elements.map {|prop| prop.value}
          rputs "from @source_elements #{@source_elements.inspect}"
          rputs "@elements are #{@elements.inspect}"
          rputs "@value is #{@value.inspect}"
        else
          @elements = values_to_elements(@value)
          rputs "from @value #{@value.inspect}"
          rputs "@elements are #{@elements.inspect}"
        end
      end

      def ruby_value
        rputs "in ruby_value #{@elements.inspect}"
        @elements.map {|prop| prop.ruby_value}
      end

      def value=(val) #:nodoc:
        super
        @elements = @value.map {|val| PropertyValue.date_or_date_time_or_period(self, :value => val)}
        case params['VALUE']
        when 'DATE-TIME', nil
          @elements = @value.map {|val| PropertyValue::DateTime.convert(self, val)}.sort
          @value = @elements.map {|element| element.value}
        when 'DATE'
          @elements = @value.map {|val| PropertyValue::Date.new(self, val)}.sort
          @value = @elements.map {|element| element.value}
        when 'PERIOD'
        end
      end
    end
    
    attr_writer :elements, :source_elements
    private :elements=, :source_elements=
    
    def for_parent(parent)
      if timezone_finder.nil?
        @timezone_finder = parent
        self
      elsif timezone_finder == parent
        self
      else
        OccurrenceList.new(parent, :value => value)
      end
    end
    
    # Return an enumerator which can produce the elements of the occurrence list
    def enumerator(component)
      OccurrenceList::Enumerator.new(@elements, component)
    end
    
    def add_date_times_to(required_timezones) #:nodoc:
      if @elements
        @elements.each do | occurrence |
          occurrence.add_date_times_to(required_timezones)
        end
      end
    end
    
  end
end