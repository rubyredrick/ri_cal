module RiCal
  class Calendar < Component
    include Properties::Calendar    
    
    def self.entity_name #:nodoc:
      "VCALENDAR"
    end
    
    # return an array of event components contained within this Calendar
    def events
      subcomponents["VEVENT"]
    end
    
    # return an array of todo components contained within this Calendar
    def todos
      subcomponents["VTODO"]
    end
    
    # return an array of journal components contained within this Calendar
    def journals
      subcomponents["VJOURNAL"]
    end
    
    # return an array of freebusy components contained within this Calendar
    def freebusys
      subcomponents["VFREEBUSY"]
    end
    
    # return an array of timezone components contained within this calendar
    def timezones
      subcomponents["VTIMEZONE"]
    end
    
  end
end
