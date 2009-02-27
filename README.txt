== RI_CAL -- a new implementation of RFC2445 in Ruby

    by Rick DeNatale
    http://talklikeaduck.denhaven2.com

== DESCRIPTION:

A new Ruby implementation of RFC2445 iCalendar.

The existing Ruby iCalendar libraries (e.g. icalendar, vpim) provide for parsing and generating icalendar files,
but do not support important things like enumerating occurrences of repeating events.

This is a clean-slate implementation of RFC2445.

== FEATURES/PROBLEMS:

* All examples of recurring events in RFC 2445 are handled. RSpec examples are provided for them. 

== SYNOPSIS:

=== Parsing

RiCal can parse icalendar data from either a string or a Ruby io object.

The data may consist of one or more icalendar calendars, or one or more icalendar compoentns (e.g. one or more 
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

*bold*:: Beware of the initial whitespace in the above example which is for rdoc formatting. The parser does not strip initial whitespace from lines in the file and will fail.

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

* FIXME (list of requirements)

== INSTALL:

This project was built using the bones gem.

For this preview release, I'm assuming that you received the code from my private git repository.

You can validate it by running
   rake
which will run all of the specs.

If you would like to use it as a gem you can use the bones rake tasks:

   rake gem
   rake gem:install

The command
   rake -T
will show additional tasks.

== LICENSE:

Copyright (c) 2009 Richard J. DeNatale

This software and associated documentation files (the
'Software') is an early access version.

A Restricted License is hereby granted, free of charge, 
to use the Software for evaluation and feedback only

This license does not grant you the permission to publish,
distribute, sublicense, or sell copies of the Software.

This license applies to previous and future versions of the software, until such time
as a version is released with a license granting additional rights,

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
