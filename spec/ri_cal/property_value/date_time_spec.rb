require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])
require 'tzinfo'

describe RiCal::PropertyValue::DateTime do
  
  def utc_datetime(string)
    RiCal::PropertyValue::DateTime.new(nil, :value => "#{string}Z")
  end
  
  def local_datetime(string, tzid = "America/New_York")
    RiCal::PropertyValue::DateTime.new(@timezone_finder, :value => string, :timezone => TZInfo::Timezone.get(tzid))
  end
  
  context "time_with_zone_methods" do
    context ".utc" do
      context "for a datetime already in zulu time" do
        before(:each) do
          @it = utc_datetime("19970101T012300").utc
        end
        
        it "should return the same datetime" do
          @it.should == utc_datetime("19970101T012300")
        end
        
        it "should return a result with a tzid of UTC" do
          @it.utc.tzid.should == "UTC"
        end
      end

      context "for a datetime with a tzid of America/New_York" do
        before(:each) do
          @it = local_datetime("19970101T012300").utc
        end
        
        it "should return the equivalent utc time" do
          @it.should == utc_datetime("19970101T062300")
        end
        
        it "should return a result with a tzid of UTC" do
          @it.tzid.should == "UTC"
        end
      end
    end

   context "for a datetime from an imported calendar" do
   
     before(:each) do
       cals = RiCal.parse_string <<-END_OF_DATA
BEGIN:VCALENDAR
METHOD:PUBLISH
X-WR-TIMEZONE:America/New_York
PRODID:-//Apple Inc.//iCal 3.0//EN
CALSCALE:GREGORIAN
X-WR-CALNAME:Test
VERSION:2.0
X-WR-RELCALID:58DB0663-196B-4B6B-A05A-A53049661280
X-APPLE-CALENDAR-COLOR:#0252D4
BEGIN:VTIMEZONE
TZID:Europe/Paris
BEGIN:DAYLIGHT
TZOFFSETFROM:+0100
TZOFFSETTO:+0200
DTSTART:19810329T020000
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU
TZNAME:CEST
END:DAYLIGHT
BEGIN:STANDARD
TZOFFSETFROM:+0200
TZOFFSETTO:+0100
DTSTART:19961027T030000
RRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU
TZNAME:CET
END:STANDARD
END:VTIMEZONE
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
SEQUENCE:3
TRANSP:OPAQUE
UID:AC2EFB19-A8A8-49EF-929F-CA0975374ED6
DTSTART:20090501T000000Z
DTSTAMP:20090501T174405Z
SUMMARY:UTC Event
CREATED:20090501T174347Z
DTEND:20090501T010000Z
END:VEVENT
BEGIN:VEVENT
SEQUENCE:2
TRANSP:OPAQUE
UID:A5517A09-C53E-4E1F-A642-EA47680BF2B6
DTSTART;TZID=US/Eastern:20090430T140000
DTSTAMP:20090501T174428Z
SUMMARY:Eastern Event
CREATED:20090501T174415Z
DTEND;TZID=US/Eastern:20090430T150000
END:VEVENT
BEGIN:VEVENT
SEQUENCE:3
TRANSP:OPAQUE
UID:B5024763-9197-4A60-A96E-D8D59D578BB2
DTSTART;TZID=Europe/Paris:20090430T140000
DTSTAMP:20090501T174509Z
SUMMARY:Paris Event
CREATED:20090501T174439Z
DTEND;TZID=Europe/Paris:20090430T150000
END:VEVENT
END:VCALENDAR
       END_OF_DATA
       @cal = cals.first
     end
     
     def find_event(summary)
       @cal.events.find {|event| event.summary == summary}
     end
     
     context ".utc" do
       context "for the DTSTART of the UTC Event" do
         before(:each) do
           @it = find_event("UTC Event").dtstart_property.utc
         end

         it "should return the same datetime" do
           @it.should == utc_datetime("20090501T000000")
         end

         it "should return a result with a tzid of UTC" do
           @it.utc.tzid.should == "UTC"
         end
       end

       context "for the DTSTART of the Eastern Event" do
         before(:each) do
           @it = find_event("Eastern Event").dtstart_property.utc
         end
       
         it "should return the equivalent utc time" do
           @it.should == utc_datetime("20090430T180000")
         end
       
         it "should return a result with a tzid of UTC" do
           @it.tzid.should == "UTC"
         end
       end
     end
   end
 end

  context ".from_separated_line" do
    it "should return a RiCal::PropertyValue::Date if the value doesn't contain a time specification" do
      RiCal::PropertyValue::DateTime.or_date(nil, :value => "19970714").should be_kind_of(RiCal::PropertyValue::Date)
    end

    it "should return a RiCal::PropertyValue::DateTime if the value does contain a time specification" do
      RiCal::PropertyValue::DateTime.or_date(nil, :value => "19980118T230000").should be_kind_of(RiCal::PropertyValue::DateTime)
    end
  end
  
  context ".advance" do
    it "should advance by one week if passed :days => 7" do
      dt1 = RiCal::PropertyValue::DateTime.new(nil, :value => "20050131T230000")
      dt2 = RiCal::PropertyValue::DateTime.new(nil, :value => "20050207T230000")
      dt1.advance(:days => 7).should == dt2
    end
  end
  
  context "subtracting one date-time from another" do
    
    it "should produce the right RiCal::PropertyValue::Duration" do
      dt1 = RiCal::PropertyValue::DateTime.new(nil, :value => "19980118T230000")
      dt2 = RiCal::PropertyValue::DateTime.new(nil, :value => "19980119T010000")
      @it = dt2 - dt1
      @it.should == RiCal::PropertyValue::Duration.new(nil, :value => "+PT2H")
    end      
  end
  
  context "adding a RiCal::PropertyValue::Duration to a RiCal::PropertyValue::DateTime" do

    it "should produce the right RiCal::PropertyValue::DateTime" do
      dt1 = RiCal::PropertyValue::DateTime.new(nil, :value => "19980118T230000")
      duration = RiCal::PropertyValue::Duration.new(nil, :value => "+PT2H")
      @it = dt1 + duration
      @it.should == RiCal::PropertyValue::DateTime.new(nil, :value => "19980119T010000")
    end
  end

  context "subtracting a RiCal::PropertyValue::Duration from a RiCal::PropertyValue::DateTime" do

    it "should produce the right RiCal::PropertyValue::DateTime" do
      dt1 = RiCal::PropertyValue::DateTime.new(nil, :value => "19980119T010000")
      duration = RiCal::PropertyValue::Duration.new(nil, :value => "+PT2H")
      @it = dt1 - duration
      @it.should == RiCal::PropertyValue::DateTime.new(nil, :value => "19980118T230000")
    end
  end

  context ".convert(rubyobject)" do
    describe "for a Time instance of  Feb 05 19:17:11"
    before(:each) do
      @time = Time.mktime(2009,2,5,19,17,11)
    end

    context "with a normal a normal time instance" do
      describe "when the default timezone identifier is UTC" do
        before(:each) do
          @it = RiCal::PropertyValue::DateTime.convert(nil, @time)
        end

        it "should have a TZID of UTC" do
          @it.tzid.should == 'UTC'
        end

        it "should have the right value" do
          @it.value.should == "20090205T191711Z"
        end
      end
      context "when the default timezone has been set to 'America/Chicago" do
        before(:each) do
          RiCal::PropertyValue::DateTime.stub!(:default_tzid).and_return("America/Chicago")
          @it = RiCal::PropertyValue::DateTime.convert(nil, @time)
        end

        it "should have a TZID of America/Chicago" do
          @it.tzid.should == 'America/Chicago'
        end

        it "should have the right value" do
          @it.value.should == "20090205T191711"
        end
      end
    end
    
    context "with an activesupport like extended time instance with time_zone returning a TZInfo::TimeZone" do
      before(:each) do
        @time.stub!(:"acts_like_time?").and_return(true)
        @time.stub!(:time_zone).and_return(mock("TZINFO_TIMEZONE", :identifier => "America/New_York"))
      end
      
      context "when the default timezone identifier is UTC" do
        before(:each) do
          @it = RiCal::PropertyValue::DateTime.convert(nil, @time)
        end
        
        it "should have the correct parameters" do
          @it.params.should == {'TZID' => 'America/New_York', 'X-RICAL-TZSOURCE' => 'TZINFO'}
        end

        it "should have a TZID of America/New_York" do
          @it.tzid.should == 'America/New_York'
        end

        it "should have the right value" do
          @it.value.should == "20090205T191711"
        end
      end
      context "when the default timezone has been set to 'America/Chicago" do
        before(:each) do
          RiCal::PropertyValue::DateTime.stub!(:default_tzid).and_return("America/Chicago")
          @it = RiCal::PropertyValue::DateTime.convert(nil, @time)
        end
        
        it "should have the correct parameters" do
          @it.params.should == {'TZID' => 'America/New_York', 'X-RICAL-TZSOURCE' => 'TZINFO'}
        end

        it "should have a TZID of America/New_York" do
          @it.tzid.should == 'America/New_York'
        end

        it "should have the right value" do
          @it.value.should == "20090205T191711"
        end
      end
    end
    
    context "with an activesupport like extended time instance with time_zone returning an ActiveSupport::TimeZone" do
      before(:each) do
        @time.stub!(:"acts_like_time?").and_return(true)
        @tzinfo_timezone = mock("TZInfo_TimeZone", :identifier => "America/New_York")
        @active_support_timezone = mock("ActiveSupport::TimeZone", :identifier => "America/New_York", :tzinfo => @tzinfo_timezone )
        @time.stub!(:time_zone).and_return(@active_support_timezone)
      end
      
      context "when the default timezone identifier is UTC" do
        before(:each) do
          @it = RiCal::PropertyValue::DateTime.convert(nil, @time)
        end
        
        it "should have the correct parameters" do
          @it.params.should == {'TZID' => 'America/New_York', 'X-RICAL-TZSOURCE' => 'TZINFO'}
        end

        it "should have a TZID of America/New_York" do
          @it.tzid.should == 'America/New_York'
        end

        it "should have the right value" do
          @it.value.should == "20090205T191711"
        end
      end
      context "when the default timezone has been set to 'America/Chicago" do
        before(:each) do
          RiCal::PropertyValue::DateTime.stub!(:default_tzid).and_return("America/Chicago")
          @it = RiCal::PropertyValue::DateTime.convert(nil, @time)
        end
        
        it "should have the correct parameters" do
          @it.params.should == {'TZID' => 'America/New_York', 'X-RICAL-TZSOURCE' => 'TZINFO'}
        end

        it "should have a TZID of America/New_York" do
          @it.tzid.should == 'America/New_York'
        end

        it "should have the right value" do
          @it.value.should == "20090205T191711"
        end
      end
    end
  end
end