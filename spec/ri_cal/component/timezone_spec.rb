require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::Component::Timezone do
  
  context ".entity_name" do
    it "should be VTIMEZONE" do
      RiCal::Component::Timezone.entity_name.should == "VTIMEZONE"
    end
  end
  
  context "from an iCal.app calendar for America/New_York starting March 11 2007" do
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
    
    context ".local_to_utc" do
      it "should produce 2/27/2009 18:00 UTC for 2/27/2009 13:00" do
        expected = RiCal::PropertyValue::DateTime.new(nil, :value => "20090227T1800Z" )
        @it.local_to_utc(DateTime.parse("Feb 27, 2009 13:00")).should == expected
      end
    end
    
    context ".utc_to_local" do
      it "should produce 2/27/2009 13:00 EST for 2/27/2009 18:00 UTC" do
        expected = RiCal::PropertyValue::DateTime.new(nil, :value => "20090227T1300Z" )
        @it.utc_to_local(DateTime.parse("Feb 27, 2009 18:00")).should == expected
      end
    end
    
    context ".periods_for_local" do
      context "for the date on which DST begins springing ahead e.g. Mar 8, 2009" do        
        it "should return a 1 element array for 1 second before the transition time" do
          @it.periods_for_local(DateTime.parse("Mar 8, 2009 1:59:59")).length.should == 1
        end
        
        it "should return an empty array for the transition time" do
          @it.periods_for_local(DateTime.parse("Mar 8, 2009 2:00:00")).should == []
        end

        it "should return an empty array for 1 second after the transition time" do
          @it.periods_for_local(DateTime.parse("Mar 8, 2009 2:00:01")).should == []
        end

        it "should return an empty array for 1 second before the spring ahead time" do
          @it.periods_for_local(DateTime.parse("Mar 8, 2009 2:59:59")).should == []
        end
        
        it "should return a 1 element array for the spring ahead time" do
          @it.periods_for_local(DateTime.parse("Mar 8, 2009 3:00:00")).length.should == 1
        end
      end

      context "for the date on which DST ends falling back e.g. Nov 11, 2009" do
        it "should return a 1 element array for 1 second before the transition time" do
          @it.periods_for_local(DateTime.parse("Nov 1, 2009 1:59:59")).length.should == 1
        end
        
        it "should return a 2 element array for the transition time" do
          @it.periods_for_local(DateTime.parse("Nov 1, 2009 2:00:00")).length.should == 2
        end
        
        it "should return a 2 element array for 1 second after the transition time" do
          @it.periods_for_local(DateTime.parse("Nov 1, 2009 2:00:01")).length.should == 2
        end
        
        it "should return a 2 element array for 59 minutes and 59 seconds after the transition time" do
          @it.periods_for_local(DateTime.parse("Nov 1, 2009 2:59:59")).length.should == 2
        end
        
        it "should return a 2 element array for 1 hour after the transition time" do
          @it.periods_for_local(DateTime.parse("Nov 1, 2009 3:00:00")).length.should == 2
        end
        
        it "should return a 2 element array for 1 hour and 1 second after the transition time" do
          @it.periods_for_local(DateTime.parse("Nov 1, 2009 3:00:01")).length.should == 2
        end
      end
    end

  end
end