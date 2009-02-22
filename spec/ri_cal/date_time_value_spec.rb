require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::DateTimeValue do

  describe ".from_separated_line" do
    it "should return a DateValue if the value doesn't contain a time specification" do
      RiCal::DateTimeValue.from_separated_line(:name => "dtstart", :value => "19970714").should be_kind_of(RiCal::DateValue)
    end

    it "should return a DateTimeValue if the value does contain a time specification" do
      RiCal::DateTimeValue.from_separated_line(:name => "dtstart", :value => "19980118T230000").should be_kind_of(RiCal::DateTimeValue)
    end
  end
  
  describe "subtracting one date-time from another" do
    
    it "should produce the right DurationValue" do
      dt1 = RiCal::DateTimeValue.new(:value => "19980118T230000")
      dt2 = RiCal::DateTimeValue.new(:value => "19980119T010000")
      @it = dt2 - dt1
      @it.should == RiCal::DurationValue.new(:value => "+PT2H")
    end      
  end
  
  describe "adding a DurationValue to a DateTimeValue" do

    it "should produce the right DateTimeValue" do
      dt1 = RiCal::DateTimeValue.new(:value => "19980118T230000")
      duration = RiCal::DurationValue.new(:value => "+PT2H")
      @it = dt1 + duration
      @it.should == RiCal::DateTimeValue.new(:value => "19980119T010000")
    end
  end

  describe "subtracting a DurationValue from a DateTimeValue" do

    it "should produce the right DateTimeValue" do
      dt1 = RiCal::DateTimeValue.new(:value => "19980119T010000")
      duration = RiCal::DurationValue.new(:value => "+PT2H")
      @it = dt1 - duration
      @it.should == RiCal::DateTimeValue.new(:value => "19980118T230000")
    end
  end

  describe ".convert(rubyobject)" do
    describe "for a Time instance of  Feb 05 19:17:11"
    before(:each) do
      @time = Time.mktime(2009,2,5,19,17,11)
    end

    describe "with a normal a normal time instance" do
      describe "when the default timezone identifier is UTC" do
        before(:each) do
          @it = RiCal::DateTimeValue.convert(@time)
        end

        it "should have a TZID of UTC" do
          @it.tzid.should == 'UTC'
        end

        it "should have the right value" do
          @it.value.should == "20090205T191711Z"
        end
      end
      describe "when the default timezone has been set to 'America/Chicago" do
        before(:each) do
          RiCal::DateTimeValue.stub!(:default_tzid).and_return("America/Chicago")
          @it = RiCal::DateTimeValue.convert(@time)
        end

        it "should have a TZID of America/Chicago" do
          @it.tzid.should == 'America/Chicago'
        end

        it "should have the right value" do
          @it.value.should == "20090205T191711"
        end
      end
    end
    
    describe "with an activesupport extended time instance" do
      before(:each) do
        @time.stub!(:"acts_like_time?").and_return(true)
        @time.stub!(:time_zone).and_return(mock("TZINFO_TIMEZONE", :identifier => "America/New_York"))
      end
      
      describe "when the default timezone identifier is UTC" do
        before(:each) do
          @it = RiCal::DateTimeValue.convert(@time)
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
      describe "when the default timezone has been set to 'America/Chicago" do
        before(:each) do
          RiCal::DateTimeValue.stub!(:default_tzid).and_return("America/Chicago")
          @it = RiCal::DateTimeValue.convert(@time)
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