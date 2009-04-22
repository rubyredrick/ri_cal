require File.join(File.dirname(__FILE__), %w[.. properties calendar.rb])

module RiCal
  class Component
    #
    # to see the property accessing methods for this class see the RiCal::Properties::Calendar module
    class Calendar < Component
      include RiCal::Properties::Calendar

      def self.entity_name #:nodoc:
        "VCALENDAR"
      end

      def required_timezones
        @required_timezones ||=  RequiredTimezones.new
      end

      # return an array of event components contained within this Calendar
      def events
        subcomponents["VEVENT"]
      end

      # add an event to the calendar
      def add_subcomponent(component)
        super(component)
        component.add_date_times_to(required_timezones)
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

      def export_required_timezones(export_stream)
        required_timezones.export_to(export_stream)
      end

      # Export this calendar as an iCalendar file.
      # if to is nil (the default) then this method will return a string,
      # otherwise to should be an IO to which the iCalendar file contents will be written
      def export(to=nil)
        export_stream = to || StringIO.new
        export_stream.puts("BEGIN:VCALENDAR")
        #TODO: right now I'm assuming that all timezones are internal what happens when we export
        #      an imported calendar.
        export_required_timezones(export_stream)
        export_subcomponent_to(export_stream, events)
        export_subcomponent_to(export_stream, todos)
        export_subcomponent_to(export_stream, journals)
        export_subcomponent_to(export_stream, freebusys)
        export_stream.puts("END:VCALENDAR")
        if to
          nil
        else
          export_stream.string
        end
      end

    end
  end
end
