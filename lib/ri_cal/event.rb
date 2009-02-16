module RiCal
  # An Event (VEVENT) calendar component groups properties describing a scheduled event.
  # Events may have multiple occurrences
  #
  # Events may also contain one or more ALARM subcomponents
  # TODO: implement alarm subcomponents
  class Event < Component
    include OccurrenceEnumerator
    include Properties::Event
    
    def self.entity_name #:nodoc:
      "VEVENT"
    end
   end
end
