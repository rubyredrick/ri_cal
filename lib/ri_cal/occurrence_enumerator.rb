module RiCal
  # OccurrenceEnumerator provides common methods for CalendarComponents that support recurrence
  # i.e. Event, Journal, Todo, and TimezonePeriod
  module OccurrenceEnumerator
    
    include Enumerable

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
        @bounded = enumerators.all? {|enumerator| enumerator.bounded?}
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
      
      def bounded?
        @bounded
      end
    end
    
    # EnumerationInstance holds the values needed during the enumeration of occurrences for a component.
    class EnumerationInstance
      include Enumerable
      
      def initialize(component, options = {})
        @component = component
        @start = options[:starting]
        @cutoff = options[:before]
        @count = options[:count]
        @rrules = OccurrenceMerger.for(@component, [@component.rrule_property, @component.rdate_property].flatten.compact)
        @exrules = OccurrenceMerger.for(@component, [@component.exrule_property, @component.exdate_property].flatten.compact)
      end
      
      # return the next exclusion which starts at the same time or after the start time of the occurrence
      # return nil if this exhausts the exclusion rules
      def exclusion_for(occurrence)
        while (@next_exclusion && @next_exclusion[:start] < occurrence[:start])
          @next_exclusion = @exrules.next_occurrence
        end
        @next_exclusion
      end

      # TODO: Need to research this, I beleive that this should also take the end time into account,
      #       but I need to research
      def exclusion_match?(occurrence, exclusion)
        exclusion && occurrence[:start] == occurrence[:start]
      end
      
      def exclude?(occurrence)
        exclusion_match?(occurrence, exclusion_for(occurrence))
      end
      
      # yield each occurrence to a block
      # some components may be open-ended, e.g. have no COUNT or DTEND 
      def each
        occurrence = @rrules.next_occurrence
        yielded = 0
        @next_exclusion = @exrules.next_occurrence
        while (occurrence)
          if (@cutoff && occurrence[:start] >= @cutoff) || (@count && yielded >= @count)
            occurrence = nil
          else
            unless exclude?(occurrence)
              yielded += 1
              yield occurrence
#              yield @component.recurrence(occurrence)
            end
            occurrence = @rrules.next_occurrence
          end
        end
      end
      
      def bounded?
        @rrules.bounded? || @count || @cutoff
      end
      
      def to_a
        raise ArgumentError.new("This component is unbounded, cannot produce an array of occurrences!") unless bounded?
        super
      end
      
      alias_method :entries, :to_a
    end
    
    # return an array of occurrences according to the options parameter
    #
    # parameter options:
    # * starting
    # * before
    def occurrences(options={})
      EnumerationInstance.new(self, options).to_a    
    end
    
    def each(&block)
      EnumerationInstance.new(self).each(&block)
    end     
  end
end