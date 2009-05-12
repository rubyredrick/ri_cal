#- ©2009 Rick DeNatale
#- All rights reserved

require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::Component::Event do

  describe ".entity_name" do
    it "should be VEVENT" do
      RiCal::Component::Event.entity_name.should == "VEVENT"
    end
  end

  context "with an rrule" do
    before(:each) do
      @it = RiCal::Component::Event.parse_string("BEGIN:VEVENT\nRRULE:FREQ=DAILY\nEND:VEVENT").first
    end

    it "should have an array of rrules" do
      @it.rrule.should be_kind_of(Array)
    end
  end

  context "description property" do
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

  context "with both dtend and duration specified" do
    before(:each) do
      @it = RiCal::Component::Event.parse_string("BEGIN:VEVENT\nDTEND:19970903T190000Z\nDURATION:H1\nEND:VEVENT").first
    end

    it "should be invalid" do
      @it.should_not be_valid
    end
  end

  context "with a duration property" do
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

  context "with a dtend property" do
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

  context "with a nested alarm component" do
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

  context ".export" do
    require 'rubygems'
    require 'tzinfo'

    def date_time_with_tzinfo_zone(date_time, timezone="America/New_York")
      date_time.dup.set_tzid(timezone)
    end
    
    # Undo the effects of RFC2445 line folding
    def unfold(string)
      string.gsub("\n ", "")
    end

    before(:each) do
      cal = RiCal.Calendar
      @it = RiCal::Component::Event.new(cal)
    end

    it "should cause a VTIMEZONE to be included for a dtstart with a local timezone" do
      @it.dtstart = date_time_with_tzinfo_zone(DateTime.parse("April 22, 2009 17:55"), "America/New_York")
      unfold(@it.export).should match(/BEGIN:VTIMEZONE\nTZID;X-RICAL-TZSOURCE=TZINFO:America\/New_York\n/)
    end

    it "should properly format dtstart with a UTC date-time" do
      @it.dtstart = DateTime.parse("April 22, 2009 1:23:45").set_tzid("UTC")
      unfold(@it.export).should match(/^DTSTART;VALUE=DATE-TIME:20090422T012345Z$/)
    end

    it "should properly format dtstart with a floating date-time" do
      @it.dtstart = DateTime.parse("April 22, 2009 1:23:45").with_floating_timezone
      unfold(@it.export).should match(/^DTSTART;VALUE=DATE-TIME:20090422T012345$/)
    end

    it "should properly format dtstart with a local time zone" do
      @it.dtstart = date_time_with_tzinfo_zone(DateTime.parse("April 22, 2009 17:55"), "America/New_York")
      unfold(@it.export).should match(/^DTSTART;TZID=America\/New_York;VALUE=DATE-TIME:20090422T175500$/)
    end

    it "should properly format dtstart with a date" do
      @it.dtstart = Date.parse("April 22, 2009")
      unfold(@it.export).should match(/^DTSTART;VALUE=DATE:20090422$/)
    end
  end
end