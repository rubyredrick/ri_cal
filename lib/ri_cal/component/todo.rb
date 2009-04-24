require File.join(File.dirname(__FILE__), %w[.. properties todo.rb])

module RiCal
  class Component
    # A Todo (VTODO) calendar component groups properties describing a to-do
    # Todos may have multiple occurrences
    #
    # Todos may also contain one or more ALARM subcomponents
    # to see the property accessing methods for this class see the RiCal::Properties::Todo module
    # to see the methods for enumerating occurrences of recurring to-dos see the RiCal::OccurrenceEnumerator module
    class Todo < Component
      include Properties::Todo

      def self.entity_name #:nodoc:
        "VTODO"
      end

      def subcomponent_class #:nodoc:
        {:alarm => Alarm }
      end
    end
  end
end
