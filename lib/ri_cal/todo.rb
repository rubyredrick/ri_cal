module RiCal
  # A Todo (VTODO) calendar component groups properties describing a to-do
  # Todos may have multiple occurrences
  #
  # Todos may also contain one or more ALARM subcomponents
  class Todo < Component
    include Properties::Todo

    def self.entity_name #:nodoc:
      "VTODO"
    end
    
  end
end
