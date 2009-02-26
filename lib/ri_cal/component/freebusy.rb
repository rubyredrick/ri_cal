require File.join(File.dirname(__FILE__), %w[.. properties freebusy.rb])

module RiCal
  class Component
    #  A Freebusy (VFREEBUSY) calendar component groups properties describing either a request for free/busy time,
    #  a response to a request for free/busy time, or a published set of busy time.
    # to see the property accessing methods for this class see the RiCal::Properties::Freebusy module
    class Freebusy < Component
      include RiCal::Properties::Freebusy        

      def self.entity_name #:nodoc:
        "VFREEBUSY"
      end
    end 
  end
end