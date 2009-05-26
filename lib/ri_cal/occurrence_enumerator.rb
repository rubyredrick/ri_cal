module RiCal
  #- ©2009 Rick DeNatale
  #- All rights reserved. Refer to the file README.txt for the license
  #
  # OccurrenceEnumerator provides common methods for CalendarComponents that support recurrence
  # i.e. Event, Journal, Todo, and TimezonePeriod
  module OccurrenceEnumerator
    
    include Enumerable

    def default_duration # :nodoc:
      dtend && dtstart.to_ri_cal_date_time_value.duration_until(dtend.to_ri_cal_date_time_value)
    end

    def default_start_time # :nodoc:
      dtstart && dtstart.to_ri_cal_date_time_value
    end

    class EmptyRulesEnumerator # :nodoc:
      def self.next_occurrence
        nil
      end
      
      def self.bounded?
        true
      end
      
      def self.empty?
        true
      end
    end
    
    # OccurrenceMerger takes multiple recurrence rules and enumerates the combination in sequence. 
    class OccurrenceMerger # :nodoc:
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
        @empty = enumerators.all? {|enumerator| enumerator.empty?}
        self.nexts = @enumerators.map {|enumerator| enumerator.next_occurrence}
      end
      
      def empty?
        @empty
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
    class EnumerationInstance # :nodoc:
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
        while (@next_exclusion && @next_exclusion.dtstart < occurrence.dtstart)
          @next_exclusion = @exrules.next_occurrence
        end
        @next_exclusion
      end

      # TODO: Need to research this, I beleive that this should also take the end time into account,
      #       but I need to research
      def exclusion_match?(occurrence, exclusion)
        exclusion && (occurrence.dtstart == exclusion.dtstart)
      end
      
      # Also exclude occurrences before the :starting date_time
      def exclude?(occurrence)
        exclusion_match?(occurrence, exclusion_for(occurrence)) ||
          (@start && occurrence.dtstart.to_datetime < @start)
      end
      
      # yield each occurrence to a block
      # some components may be open-ended, e.g. have no COUNT or DTEND 
      def each
        if @rrules.empty?
          yield @component
        else
          occurrence = @rrules.next_occurrence
          yielded = 0
          @next_exclusion = @exrules.next_occurrence
          while (occurrence)
            if (@cutoff && occurrence.dtstart.to_datetime >= @cutoff) || (@count && yielded >= @count)
              occurrence = nil
            else
              unless exclude?(occurrence)
                yielded += 1
                yield @component.recurrence(occurrence)
              end
              occurrence = @rrules.next_occurrence
            end
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
    
    # return an array of occurrences according to the options parameter.  If a component is not bounded, and
    # the number of occurrences to be returned is not constrained by either the :before, or :count options
    # an ArgumentError will be raised.
    #
    # The components returned will be the same type as the receiver, but will have any recurrence properties
    # (rrule, rdate, exrule, exdate) removed since they are single occurrences, and will have the recurrence-id
    # property set to the occurrences dtstart value. (see RFC 2445 sec 4.8.4.4 pp 107-109)
    #
    # parameter options:
    # * :starting:: a Date, Time, or DateTime, no occurrences starting before this argument will be returned
    # * :before:: a Date, Time, or DateTime, no occurrences starting on or after this argument will be returned. 
    # * :count:: an integer which limits the number of occurrences returned.
    def occurrences(options={})
      EnumerationInstance.new(self, options).to_a    
    end
    
    # execute the block for each occurrence
    def each(&block) # :yields: Component
      EnumerationInstance.new(self).each(&block)
    end
    
    # A predicate which determines whether the component has a bounded set of occurrences
    def bounded?
      EnumerationInstance.new(self).bounded?
    end
    
    # Return a array whose first element is a UTC DateTime representing the start of the first
    # occurrence, and whose second element is a UTC DateTime representing the end of the last
    # occurrence.
    # If the receiver is not bounded then the second element will be nil.
    #
    # The purpose of this method is to provide values which may be used as database attributes so
    # that a query can find all occurence enumerating components which may have occurrences within
    # a range of times.
    def zulu_occurrence_range
      if bounded?
        all = occurrences
        first, last = all.first, all.last
      else
        first = occurrences(:count => 1).first
        last = nil
      end
      [first.zulu_occurrence_range_start_time, last ? last.zulu_occurrence_range_finish_time : nil]
    end
    
    def set_occurrence_properties!(occurrence) # :nodoc:
      occurrence_end = occurrence.dtend
      occurrence_start = occurrence.dtstart
      @rrule_property = nil
      @exrule_property = nil
      @rdate_property = nil
      @exdate_property = nil
      @recurrence_id_property = occurrence_start
      if @dtend_property && !occurrence_end
        occurrence_end = occurrence_start + (@dtend_property - @dtstart_property)
      end
      @dtstart_property = dtstart_property.for_occurrence(occurrence_start)
      @dtend_property = dtend_property.for_occurrence(occurrence_end) if @dtend_property
      self      
    end
    
    def recurrence(occurrence) # :nodoc:
      result = self.dup.set_occurrence_properties!(occurrence)
    end
  end
end