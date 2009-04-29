require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::Component::Timezone do
  
  describe ".entity_name" do
    it "should be VTIMEZONE" do
      RiCal::Component::Timezone.entity_name.should == "VTIMEZONE"
    end
  end
  
  describe "from an iCal.app calendar for America/New_York starting March 11 2007" do
    before(:each) do
      @it = RiCal.parse_string <<TZEND
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
TZEND
      @it = @it.first
    end
    
    it "should be a Timezone" do
      @it.should be_kind_of(RiCal::Component::Timezone)
    end
    
    describe ".local_to_utc" do
      it "should produce 2/27/2009 18:00 UTC for 2/27/2009 13:00" do
        expected = RiCal::PropertyValue::DateTime.new(nil, :value => "20090227T1800Z" )
        @it.local_to_utc(DateTime.parse("Feb 27, 2009 13:00")).should == expected
      end
    end
    
    describe ".utc_to_local" do
      it "should produce 2/27/2009 13:00 EST for 2/27/2009 18:00 UTC" do
        expected = RiCal::PropertyValue::DateTime.new(nil, :value => "20090227T1300Z" )
        @it.utc_to_local(DateTime.parse("Feb 27, 2009 18:00")).should == expected
      end
    end
    
  end
end