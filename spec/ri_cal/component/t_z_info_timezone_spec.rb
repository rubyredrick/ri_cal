require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])
require 'rubygems'
require 'tzinfo'

describe RiCal::Component::TZInfoTimezone do

  it "should produce an rfc representation" do
    tz = RiCal::Component::TZInfoTimezone.new(TZInfo::Timezone.get("America/New_York"))
    rez = tz.to_rfc2445_string(tz.local_to_utc(DateTime.parse("Apr 10, 1997")),
    tz.local_to_utc(DateTime.parse("Apr 6, 1998")))
    rez.should == <<-ENDDATA
BEGIN:VTIMEZONE
TZID;X-RICAL-TZSOURCE=TZINFO:America/New_York
BEGIN:DAYLIGHT
DTSTART:19970406T030000
RDATE:19970406T030000
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
TZNAME:EDT
END:DAYLIGHT
BEGIN:STANDARD
DTSTART:19971026T010000
RDATE:19971026T010000
TZOFFSETFROM:-0400
TZOFFSETTO:-0500
TZNAME:EST
END:STANDARD
BEGIN:DAYLIGHT
DTSTART:19980405T030000
RDATE:19980405T030000
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
TZNAME:EDT
END:DAYLIGHT
END:VTIMEZONE
ENDDATA
  end
end