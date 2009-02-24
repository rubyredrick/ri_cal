require File.join(File.dirname(__FILE__), %w[.. properties journal.rb])

module RiCal
  class Component
    #  A Journal (VJOURNAL) calendar component groups properties describing a journal entry.
    #  Journals may have multiple occurrences
    class Journal < Component
      include RiCal::Properties::Journal

      def self.entity_name #:nodoc:
        "VJOURNAL"
      end
    end
  end
end
