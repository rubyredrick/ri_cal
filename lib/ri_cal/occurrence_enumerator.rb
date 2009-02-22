module RiCal
  # OccurrenceEnumerator provides common methods for CalendarComponents that support recurrence
  # i.e. Event, Journal, Todo, and TimezonePeriod
  module OccurrenceEnumerator

    def default_duration     
      dtend && dtstart.to_ri_cal_date_time_value.duration_until(dtend)
    end

    def default_start_time
      dtstart && dtstart.to_ri_cal_date_time_value
    end

    class EmptyRulesEnumerator
      def self.next_occurrence
        nil
      end
    end
    
    # OccurrenceMerger takes multiple recurrence rules and enumerates the combination in sequence. 
    class OccurrenceMerger
      def self.for(component, rules)
        if rules.nil? || rules.empty?
          EmptyRulesEnumerator
        elsif rules.length == 1
          rules.first.enumerator(component)
        else
          new(component, rules)
        end
      end
      
      attr_accessor :enumerators, :nexts
      
      def initialize(component, rules)
        self.enumerators = rules.map {|rrule| rrule.enumerator(component)}
        self.nexts = @enumerators.map {|enumerator| enumerator.next_occurrence}
      end
      
      # return the earliest of each of the enumerators next occurrences
      def next_occurrence        
        result = nexts.compact.sort.first
        if result
          nexts.each_with_index { |datetimevalue, i| @nexts[i] = @enumerators[i].next_occurrence if result == datetimevalue }
        end
        result
      end
    end
    
    # EnumerationInstance holds the values needed during the enumeration of occurrences for a component.
    class EnumerationInstance
      def initialize(options, component)
        @component = component
        @start = options[:starting]
        @cutoff = options[:before]
        @rrules = OccurrenceMerger.for(@component, @component.rrule)
        @exrules = OccurrenceMerger.for(@component, @component.exrule)
      end
      
      # yield each occurrence to a block
      # some components may be open-ended, e.g. have no COUNT or DTEND 
      def each_occurrence
      end
    end
    
    # return an array of occurrences according to the options parameter
    #
    # parameter options:
    # * starting
    # * before
    def occurrences(options={})
      EnumerationInstance.new(options, self).occurrences      
    end
  end
end