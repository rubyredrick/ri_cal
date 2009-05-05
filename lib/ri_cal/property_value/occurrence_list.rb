module RiCal
  class PropertyValue
    # OccurrenceList is used to represent the value of an RDATE or EXDATE property.
    #- ©2009 Rick DeNatale
    #- All rights reserved. Refer to the file README.txt for the license
    #
    class OccurrenceList < Array
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
      
      
      def self.convert(timezone_finder, ruby_object) # :nodoc:
        if PropertyValue::DateTime.single_time_or_date?(ruby_object)
          values = [ruby_object]
        else
          values = ruby_object
        end
        super(timezone_finder, values)
      end

      def value=(val) #:nodoc:
        super
        case params[:value]
        when 'DATE-TIME', nil
          @elements = @value.map {|val| PropertyValue::DateTime.convert(self, val)}.sort
        when 'DATE'
          @elements = @value.map {|val| PropertyValue::Date.new(self, val)}.sort
        when 'PERIOD'
        end
      end
    end
    
    attr_writer :elements
    private :elements=
    
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