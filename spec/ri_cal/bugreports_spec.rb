#- ©2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license

require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe "http://rick_denatale.lighthouseapp.com/projects/30941/tickets/17" do
  it "should parse this" do
    RiCal.parse_string(<<-ENDCAL)
BEGIN:VCALENDAR
PRODID:-//Google Inc//Google Calendar 70.9054//EN
VERSION:2.0
CALSCALE:GREGORIAN
METHOD:PUBLISH
X-WR-CALNAME:Australian Tech Events
X-WR-TIMEZONE:Australia/Sydney
X-WR-CALDESC:TO ADD EVENTS INVITE THIS ADDRESS\;\npf44opfb12hherild7h2pl11b
 4@group.calendar.google.com\n\nThis is a public calendar to know what's com
 ing up all around the country in the technology industry.\n\nIncludes digit
 al\, internet\, web\, enterprise\, software\, hardware\, and it's various f
 lavours. \n\nFeel free to add real events. Keep it real. 
BEGIN:VTIMEZONE
TZID:Australia/Perth
X-LIC-LOCATION:Australia/Perth
BEGIN:STANDARD
TZOFFSETFROM:+0800
TZOFFSETTO:+0800
TZNAME:WST
DTSTART:19700101T000000
END:STANDARD
END:VTIMEZONE
BEGIN:VTIMEZONE
TZID:Australia/Sydney
X-LIC-LOCATION:Australia/Sydney
BEGIN:STANDARD
TZOFFSETFROM:+1100
TZOFFSETTO:+1000
TZNAME:EST
DTSTART:19700405T030000
RRULE:FREQ=YEARLY;BYMONTH=4;BYDAY=1SU
END:STANDARD
BEGIN:DAYLIGHT
TZOFFSETFROM:+1000
TZOFFSETTO:+1100
TZNAME:EST
DTSTART:19701004T020000
RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=1SU
END:DAYLIGHT
END:VTIMEZONE
BEGIN:VTIMEZONE
TZID:Australia/Brisbane
X-LIC-LOCATION:Australia/Brisbane
BEGIN:STANDARD
TZOFFSETFROM:+1000
TZOFFSETTO:+1000
TZNAME:EST
DTSTART:19700101T000000
END:STANDARD
END:VTIMEZONE
BEGIN:VEVENT
DTSTART:20091110T080000Z
DTEND:20091110T100000Z
DTSTAMP:20090720T133540Z
UID:9357CC6B-C4BF-4797-AC5F-83E47C3FDA9E
URL:thehive.org.au
CLASS:PUBLIC
CREATED:20090713T123838Z
DESCRIPTION:check the website for details
LAST-MODIFIED:20090713T123838Z
LOCATION:Melbourne
SEQUENCE:1
STATUS:CONFIRMED
SUMMARY:The Hive MELBOURNE
TRANSP:OPAQUE
BEGIN:VALARM
ACTION:AUDIO
TRIGGER:-PT5M
X-WR-ALARMUID:F92A055A-2CD9-4FB2-A22A-BD4834ACEE96
ATTACH;VALUE=URI:Basso
END:VALARM
END:VEVENT
END:VCALENDAR
ENDCAL
  end
end

describe "http://rick_denatale.lighthouseapp.com/projects/30941/tickets/18" do
  it "should handle a subcomponent" do
    event = RiCal.Event do |evt|
      evt.alarm do |alarm|
        alarm.trigger = "-PT5M"
        alarm.action = 'AUDIO'
      end
    end
    
    lambda {event.export}.should_not raise_error
  end
end

describe "http://rick_denatale.lighthouseapp.com/projects/30941/tickets/19" do
  before(:each) do
    cals = RiCal.parse_string(<<-ENDCAL)
BEGIN:VCALENDAR
METHOD:REQUEST
PRODID:Microsoft CDO for Microsoft Exchange
VERSION:2.0
BEGIN:VTIMEZONE
TZID:(GMT-05.00) Eastern Time (US & Canada)
X-MICROSOFT-CDO-TZID:10
BEGIN:STANDARD
DTSTART:16010101T020000
TZOFFSETFROM:-0400
TZOFFSETTO:-0500
RRULE:FREQ=YEARLY;WKST=MO;INTERVAL=1;BYMONTH=11;BYDAY=1SU
END:STANDARD
BEGIN:DAYLIGHT
DTSTART:16010101T020000
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
RRULE:FREQ=YEARLY;WKST=MO;INTERVAL=1;BYMONTH=3;BYDAY=2SU
END:DAYLIGHT
END:VTIMEZONE
BEGIN:VEVENT
DTSTAMP:20090724T143205Z
DTSTART;TZID="(GMT-05.00) Eastern Time (US & Canada)":20090804T120000
SUMMARY:FW: ALL HANDS MEETING
DTEND;TZID="(GMT-05.00) Eastern Time (US & Canada)":20090804T133000
DESCRIPTION:Some event
END:VEVENT
END:VCALENDAR
ENDCAL
    
    @event = cals.first.events.first
  end
  
  it "not raise an error accessing DTSTART" do
    lambda {@event.dtstart}.should_not raise_error
  end
end