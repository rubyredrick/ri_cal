require File.join(File.dirname(__FILE__), %w[.. properties calendar.rb])

module RiCal
  class Component
    #- ©2009 Rick DeNatale
    #- All rights reserved. Refer to the file README.txt for the license
    #
    # to see the property accessing methods for this class see the RiCal::Properties::Calendar module
    class Calendar < Component
      include RiCal::Properties::Calendar
      attr_reader :tz_source

      def initialize(parent=nil, &init_block) #:nodoc:
        super
        @tz_source = 'TZINFO' # Until otherwise told
      end

      def self.entity_name #:nodoc:
        "VCALENDAR"
      end

      def tz_info_source?
        @tz_source == 'TZINFO'
      end

      def required_timezones # :nodoc:
        @required_timezones ||=  RequiredTimezones.new
      end

      def subcomponent_class # :nodoc:
        {
          :event => Event,
          :todo  => Todo,
          :journal => Journal,
          :freebusy => Freebusy,
          :timezone => Timezone,
        }
      end

      def export_properties_to(export_stream) # :nodoc:
        prodid_property.params["X-RICAL-TZSOURCE"] = @tz_source
        export_prop_to(export_stream, "PRODID", prodid_property)
        export_prop_to(export_stream, "CALSCALE", calscale_property)
        export_prop_to(export_stream, "VERSION", version_property)
        export_prop_to(export_stream, "METHOD", method_property)
      end

      def prodid_property_from_string(line) # :nodoc:
        result = super
        @tz_source = prodid_property.params["X-RICAL-TZSOURCE"]
        result
      end

      # return an array of event components contained within this Calendar
      def events
        subcomponents["VEVENT"]
      end

      # add an event to the calendar
      def add_subcomponent(component)
        super(component)
        component.add_date_times_to(required_timezones) if tz_info_source?
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

      class TimezoneID
        attr_reader :identifier, :calendar
        def initialize(identifier, calendar)
          self.identifier, self.calendar = identifier, calendar
        end

        def tzinfo_timezone
          nil
        end

        def resolved
          calendar.find_timezone(identifier)
        end

        def local_to_utc(local)
          resolved.local_to_utc(date_time_prop)
        end
      end

      # return an array of timezone components contained within this calendar
      def timezones
        subcomponents["VTIMEZONE"]
      end
      
      class TZInfoWrapper
        attr_reader :tzinfo, :calendar
        def initialize(tzinfo, calendar)
          @tzinfo = tzinfo
          @calendar = calendar
        end
        
        def identifier
          tzinfo.identifier
        end
        
        def date_time(ruby_time, tzid)
          RiCal::PropertyValue::DateTime.new(calendar, :value => ruby_time, :params => {'TZID' => tzid})
        end
        
        def local_to_utc(utc)
          date_time(tzinfo.local_to_utc(utc.to_ri_cal_ruby_value), 'UTC')
        end
        
        def utc_to_local(local)
          date_time(tzinfo.utc_to_local(local.to_ri_cal_ruby_value), tzinfo.identifier)
        end
      end

      def find_timezone(identifier)
        if tz_info_source?
          TZInfoWrapper.new(TZInfo::Timezone.get(identifier), self)
        else
          timezones.find {|tz| tz.tzid == identifier}
        end
      end

      def export_required_timezones(export_stream) # :nodoc:
        required_timezones.export_to(export_stream)
      end

      class FoldingStream
        attr_reader :stream
        def initialize(stream)
          @stream = stream || StringIO.new
        end

        def string
          stream.string
        end

        def fold(string)
          stream.puts(string[0,73])
          string = string[73..-1]
          while string
            stream.puts " #{string[0, 72]}"
            string = string[72..-1]
          end
        end

        def puts(*strings)
          strings.each do |string|
            string.split("\n").each do |line|
              fold(line)
            end
          end
        end
      end

      # Export this calendar as an iCalendar file.
      # if to is nil (the default) then this method will return a string,
      # otherwise to should be an IO to which the iCalendar file contents will be written
      def export(to=nil)
        export_stream = FoldingStream.new(to)
        export_stream.puts("BEGIN:VCALENDAR")
        #TODO: right now I'm assuming that all timezones are internal what happens when we export
        #      an imported calendar.
        export_properties_to(export_stream)
        export_x_properties_to(export_stream)
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
