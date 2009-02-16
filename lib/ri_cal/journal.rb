module RiCal
  #  A Journal (VJOURNAL) calendar component groups properties describing a journal entry.
  #  Journals may have multiple occurrences
  class Journal < Component
    include Properties::Journal

    def self.entity_name #:nodoc:
      "VJOURNAL"
    end
  end
end
