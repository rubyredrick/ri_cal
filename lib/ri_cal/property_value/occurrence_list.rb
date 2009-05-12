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
      end

      def self.convert(timezone_finder, *ruby_objects) # :nodoc:
        new(timezone_finder, :source_elements => ruby_objects )
      end

      def value_to_element(value)
        if ::String === value
          result = PropertyValue.date_or_date_time_or_period(self, :value => value)
          result.tzid = tzid if tzid
          result
        else
          value.to_ri_cal_property_value
        end
      end


      def values_to_elements(values)
        values.map {|val| value_to_element(val)}
      end
      
      def tzid_from_source_elements
        if @source_elements && String === (first_source = @source_elements.first)
          unless PropertyValue::DateTime.valid_string?(first_source) || 
            PropertyValue::Date.valid_string?(first_source) || 
            PropertyValue::Period.valid_string?(first_source)
            return @source_elements.shift
          end
        end
        nil
      end
      
      def self.occurence_list_property_from_string(timezone_finder, string)
        PropertyValue::DateTime.if_valid_string(timezone_finder, string) ||
        PropertyValue::Date.if_valid_string(timezone_finder, string) ||
        PropertyValue::Period.if_valid_string(timezone_finder, string)
      end

      def validate_elements
        if @source_elements
          self.tzid = tzid_from_source_elements
          @elements = values_to_elements(@source_elements)
          @value = @elements.map {|prop| prop.value}
        else
          @elements = values_to_elements(@value)
        end
        # if the tzid wasn't set by the parameters
        self.tzid ||= @elements.map {|element| element.tzid}.find {|id| id}
        # Todo figure out what to do if an element already has a different tzid
        @elements.each do |element|
          element.tzid = tzid
        end
      end

      def has_local_timezone?
        tzid && tzid != 'UTC'
      end

      def visible_params # :nodoc:
        result = params.dup
        if has_local_timezone?
          result['TZID'] = tzid
        else
          result.delete('TZID')
        end
        result
      end

      def value
        @elements.map {|element| element.value}.join(",")
      end

      def ruby_value
        @elements.map {|prop| prop.ruby_value}
      end
    end

    attr_accessor :elements, :source_elements
    private :elements, :elements=, :source_elements=, :source_elements

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