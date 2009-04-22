require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::Component::Event do
  
  describe ".entity_name" do
    it "should be VEVENT" do
      RiCal::Component::Event.entity_name.should == "VEVENT"
    end
  end
  
  describe "with an rrule" do
    before(:each) do
      @it = RiCal::Component::Event.parse_string("BEGIN:VEVENT\nRRULE:FREQ=DAILY\nEND:VEVENT").first
    end
    
    it "should have an array of rrules" do
      @it.rrule.should be_kind_of(Array)
    end
  end
  
  describe "description property" do
    before(:each) do
      @ical_desc = "posted by Joyce per Zan\\nASheville\\, Rayan's Restauratn\\, Biltm\n ore Square"
      @ruby_desc = "posted by Joyce per Zan\nASheville, Rayan's Restauratn, Biltmore Square"
      @it = RiCal::Component::Event.parse_string("BEGIN:VEVENT\nDESCRIPTION:#{@ical_desc}\nEND:VEVENT").first
    end
    
    it "should product the converted ruby value" do
      @it.description.should == @ruby_desc      
    end
    
    it "should produce escaped text for ical" do
      @it.description = "This is a\nnew description, yes; it is"
      @it.description_property.value.should == 'This is a\nnew description\, yes\; it is'
    end
    
  end

  describe "with both dtend and duration specified" do
    before(:each) do
      @it = RiCal::Component::Event.parse_string("BEGIN:VEVENT\nDTEND:19970903T190000Z\nDURATION:H1\nEND:VEVENT").first
    end
    
    it "should be invalid" do
      @it.should_not be_valid
    end
  end

  describe "with a duration property" do
    before(:each) do
      @it = RiCal::Component::Event.parse_string("BEGIN:VEVENT\nDURATION:H1\nEND:VEVENT").first
    end

    it "should have a duration property" do
      @it.duration_property.should be
    end
    
    it "should have a duration of 1 Hour" do
      @it.duration_property.value.should == "H1"
    end
    
    it "should reset the duration property if the dtend property is set" do
      @it.dtend_property = "19970101".to_ri_cal_date_time_value
      @it.duration_property.should be_nil
    end
    
    it "should reset the duration property if the dtend ruby value is set" do
      @it.dtend = "19970101"
      @it.duration_property.should == nil
    end
  end

  describe "with a dtend property" do
    before(:each) do
      @it = RiCal::Component::Event.parse_string("BEGIN:VEVENT\nDTEND:19970903T190000Z\nEND:VEVENT").first
    end

    it "should have a duration property" do
      @it.dtend_property.should be
    end
    
    it "should reset the dtend property if the duration property is set" do
      @it.duration_property = "H1".to_ri_cal_duration_value
      @it.dtend_property.should be_nil
    end
    
    it "should reset the dtend property if the duration ruby value is set" do
      @it.duration = "H1".to_ri_cal_duration_value
      @it.dtend_property.should be_nil
    end
  end
  
  describe "with a nested alarm component" do
    before(:each) do
      @it = RiCal::Component::Event.parse_string("BEGIN:VEVENT\nDTEND:19970903T190000Z\n\nBEGIN:VALARM\nEND:VALARM\nEND:VEVENT").first
    end
    
    it "should have one alarm" do
      @it.alarms.length.should == 1
    end
    
    it "which should be an Alarm component" do
      @it.alarms.first.should be_kind_of(RiCal::Component::Alarm)
    end
  end
  
  describe ".export" do
    require 'rubygems'
    require 'tzinfo'
    
    def date_time_with_tzinfo_zone(date_time, timezone="America/New_York")
      result = date_time.dup
      result.stub!(:acts_like_time?).and_return(true)
      time_zone = TZInfo::Timezone.get(timezone)
      result.stub!(:time_zone).and_return(time_zone)
      result
    end

    before(:each) do
      @it = RiCal::Component::Event.new
    end
    
    it "should succeed" do
      @it.export.should == "BEGIN:VCALENDAR\nBEGIN:VEVENT\nEND:VEVENT\nEND:VCALENDAR\n"
    end
    
    it "should cause a VTIMEZONE to be included for a dtstart with a local timezone" do
      @it.dtstart = date_time_with_tzinfo_zone(DateTime.parse("4/22/2009 17:55"), "America/New_York")
      @it.export.should match(/BEGIN:VTIMEZONE\nTZID;X-RICAL-TZSOURCE=TZINFO:America\/New_York\n/)    
    end
  end
end