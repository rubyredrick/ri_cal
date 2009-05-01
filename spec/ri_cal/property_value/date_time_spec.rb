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