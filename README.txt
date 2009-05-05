== RI_CAL -- a new implementation of RFC2445 in Ruby
http://rical.rubyforge.org/

    by Rick DeNatale
== DESCRIPTION:

This is an UNOFFICIAL version.  The public official version will be released on RubyForge.  Github will be used
for interim versions.  USE THIS VERSION AT YOUR OWN RISK.

A new Ruby implementation of RFC2445 iCalendar.

The existing Ruby iCalendar libraries (e.g. icalendar, vpim) provide for parsing and generating icalendar files,
but do not support important things like enumerating occurrences of repeating events.

This is a clean-slate implementation of RFC2445.

== FEATURES/PROBLEMS:

* All examples of recurring events in RFC 2445 are handled. RSpec examples are provided for them. 

== SYNOPSIS:

=== Components and properties

An iCalendar calendar comprises subcomponents like Events, Timezones and Todos.  Each component may have
properties, for example an event has a dtstart property which defines the time (and date) on which the event
starts.

RiCal components will provide reasonable ruby objects as the values of these properties, and allow the properties
to be set to ruby objects which are reasonable for the particular property.  For example time properties like dtstart
can be set to a ruby Time, DateTime or Date object, and will return a DateTime or Date object when queried.

The methods for accessing the properties of each type of component are defined in a module with the same name
as the component class in the RiCal::properties module.  For example the property accessing methods for 
RiCal::Component::Event are defined in RiCal::Properties::Event

=== Creating Calendars and Calendar Components

RiCal provides a builder DSL for creating calendars and calendar components. An example

  RiCal.Calendar do
    event do
      description "MA-6 First US Manned Spaceflight"
      dtstart     DateTime.parse("2/20/1962 14:47:39")
      dtend       DateTime.parse("2/20/1962 19:43:02")
      location    "Cape Canaveral"
      add_attendee "john.glenn@nasa.gov"
      alarm do
        description "Segment 51"
      end
    end
  end
  
This style is for compatibility with the iCalendar and vpim to ease migration.  The downside is that the block is evaluated
in the context of a different object which cause surprising if the block contains direct instance variable references or
implicit references to self.  Note that, in this style, one must use 'declarative' method calls like dtstart to set values
rather than more natural attribute writer methods, like dtstart=
  
Alternatively you can pass a block with a single argument, in this case the component being built will be passed as that argument

  RiCal.Calendar do |cal|
    cal.event do |event|
      event.description = "MA-6 First US Manned Spaceflight"
      event.dtstart =  DateTime.parse("2/20/1962 14:47:39")
      event.dtend = DateTime.parse("2/20/1962 19:43:02")
      event.location = "Cape Canaveral"
      event.add_attendee "john.glenn@nasa.gov"
      event.alarm do
        description "Segment 51"
      end
    end
  end

As the example shows, the two styles can be mixed, the inner block which builds the alarm uses the first style.
  
The blocks are evaluated in the context of an object which builds the calendar or calendar component. method names
starting with add_ or remove_ are sent to the component, method names which correspond to a property value setter of
the object being built will cause that setter to be sent to the component with the provided value.

A method corresponding to the name of one of the components sub component will create the sub component and 
evaluate the block in the context of the new subcomponent.

=== Times, Time zones, and Floating Times

RFC2445 describes three different kinds of DATE-TIME values with respect to time zones:

  1. date-times with a local time. These have no actual time zone, instead they are to be interpreted in the local time zone of the viewer.  These floating times are used for things like the New Years celebration which is observed at local midnight whether you happen to be in Paris, London, or New York.

  2. date-times with UTC time.  An application would either display these with an indication of the time zone, or convert them to the viewer's time zone, perhaps depending on user settings.

  3. date-times with a specified time zone.

RiCal can be given ruby Time, DateTime, or Date objects for the value of properties requiring an 
iCalendar DATE-TIME value. It can also be given a two element array where the first element is a Time or DateTime,
and the second is a string representation of the time zone identifier.

Note that a date only DATE-TIME value has no time zone by definition, effectively such values float and describe
a date as viewed by the user in his/her local time zone.

When a Ruby Time or DateTime instance is used to set properties with with a DATE-TIME value, it needs to determine
which of the three types it represents.  RiCal is designed to make use of the TimeWithZone support which has been
part of the ActiveSupport component of Ruby on Rails since Rails 2.2. However it's been carefully designed not
to require Rails or ActiveSupport, but to dynamically detect the presence of the TimeWithZone support.

When the value of a DATE-TIME property is set to a value, the following processing occurs:

* If the object responds to both the :acts_as_time, and :timezone methods then the result of the timezone method (assumed to be an instance of TZInfoTimezone) is used as a specific local time zone.

* If not then the default time zone id is used.  The normal default timezone id is "UTC". You can set the default by calling ::RiCal::PropertyValue::DateTime.default_tzid = timezone_identifier, where timezone_identifier isa string, or nil.  If you set the default tzid to 'none' or :none, then Times or DateTimes without timezones will be treated as floating times.

Note it is likely that in a future version of RiCal that the default timezone will be set on a Calendar by Calendar
basis rather than on the DateTime property class.

Also note that time zone identifiers are not standardized by RFC 2445. For an RiCal originated calendar
time zone identifiers recognized by the TZInfo gem, or the TZInfo implementation provided by ActiveSupport as the case
may be may be used.  The valid time zone identifiers for a non-RiCal generated calendar imported into RiCalendar
are determined by the VTIMEZONE compoents within the imported calendar.

If you use a timezone identifer within a calendar which is not defined within the calendar it will detected at the time
you try to convert a timezone. In this case an InvalidTimezoneIdentifier error will be raised by the conversion method.

To explicitly set a floating time you can use the method #with_floating_timezone on Time or DateTime instances as in

   event.dtstart = Time.parse("1/1/2010 00:00:00").with_floating_timezone

=== Parsing

RiCal can parse icalendar data from either a string or a Ruby io object.

The data may consist of one or more icalendar calendars, or one or more icalendar components (e.g. one or more 
VEVENT, or VTODO objects.)

In either case the result will be an array of components.
==== From a string
	RiCal.parse_string <<ENDCAL
	BEGIN:VCALENDAR
	X-WR-TIMEZONE:America/New_York
	PRODID:-//Apple Inc.//iCal 3.0//EN
	CALSCALE:GREGORIAN
	X-WR-CALNAME:test
	VERSION:2.0
	X-WR-RELCALID:1884C7F8-BC8E-457F-94AC-297871967D5E
	X-APPLE-CALENDAR-COLOR:#2CA10B
	BEGIN:VTIMEZONE
	TZID:US/Eastern
	BEGIN:DAYLIGHT
	TZOFFSETFROM:-0500
	TZOFFSETTO:-0400
	DTSTART:20070311T020000
	RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU
	TZNAME:EDT
	END:DAYLIGHT
	BEGIN:STANDARD
	TZOFFSETFROM:-0400
	TZOFFSETTO:-0500
	DTSTART:20071104T020000
	RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU
	TZNAME:EST
	END:STANDARD
	END:VTIMEZONE
	BEGIN:VEVENT
	SEQUENCE:5
	TRANSP:OPAQUE
	UID:00481E53-9258-4EA7-9F8D-947D3041A3F2
	DTSTART;TZID=US/Eastern:20090224T090000
	DTSTAMP:20090225T000908Z
	SUMMARY:Test Event
	CREATED:20090225T000839Z
	DTEND;TZID=US/Eastern:20090224T100000
	RRULE:FREQ=DAILY;INTERVAL=1;UNTIL=20090228T045959Z
	END:VEVENT
	END:VCALENDAR
	ENDCAL

<b>Beware of the initial whitespace in the above example which is for rdoc formatting.</b> The parser does not strip initial whitespace from lines in the file and will fail.

As already stated the string argument may be a full icalendar format calendar, or just one or more subcomponents, e.g.

RiCal.parse_string("BEGIN:VEVENT\nDTSTART;TZID=US/Eastern:20090224T090000\nSUMMARY:Test Event\nDTEND;TZID=US/Eastern:20090224T100000\nRRULE:FREQ=DAILY;INTERVAL=1;UNTIL=20090228T045959Z\nEND:VEVENT")

==== From an Io
	File.open("path/to/file", "r") do |file|
	    components = RiCal.parse(file)
	end

=== Occurrence Enumeration

Event, Journal, and Todo components can have recurrences which are defined following the RFC 2445 specification.
A component with recurrences can enumerate those occurrences.

These components have common methods for enumeration which are defined in the RiCal::OccurrenceEnumerator module.

==== Obtaining an array of occurrences

To get an array of occurrences, Use the RiCal::OccurrenceEnumerator#occurrences method:

	event.occurrences

This method may fail with an argument error, if the component has an unbounded recurrence definition. This happens
when one or more of its RRULES don't have a COUNT, or UNTIL part.  This may be tested by using the RiCal::OccurrenceEnumerator#bounded? method.

In the case of unbounded components, you must either use the :count, or :before options of the RiCal::OccurrenceEnumerator#occurrences method:

	event.occurrences(:count => 10)

or

  event.occurrences(:before => Date.today >> 1)

Alternately, you can use the RiCal::OccurrenceEnumerator#each method,
or another Enumerable method (RiCal::OccurrenceEnumerator includes Enumerable), and terminate when you wish by breaking out of the block.

	event.each do |event|
	   break if some_termination_condition
	   #....
	end

== REQUIREMENTS:

* RiCal requires that an implementation of TZInfo::Timezone. This requirement may be satisfied by either the TzInfo gem,
or by a recent(>= 2.2) version of the ActiveSupport gem which is part of Ruby on Rails.

== INSTALL:

=== From RubyForge

    sudo gem install ri_cal
    
=== From github

    #TODO: publish to github

==== As a Gem

    #TODO: add the gem source info for github
    sudo gem install ????? --source http://github.com/????
   
==== From source

    1. cd to a directory in which you want to install ri_cal as a subdirectory
    2. git clone http://github.com/rubyredrick/ri_cal  your_install_subdirectory
    3. cd your_install_directory
    4. rake spec
    5. rake install_gem



== LICENSE:

(The MIT License)

Copyright (c) 2009 Richard J. DeNatale

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.