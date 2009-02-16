module RiCal
  #  A Freebusy (VFREEBUSY) calendar component groups properties describing either a request for free/busy time,
  #  a response to a request for free/busy time, or a published set of busy time.
  class Freebusy < Component
    include Properties::Freebusy        

    def self.entity_name #:nodoc:
      "VFREEBUSY"
    end
  end 
end
