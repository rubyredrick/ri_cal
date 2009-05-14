#- ©2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license

require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::Component::Event do

  context "rdate property methods" do
    before(:each) do
      @event = RiCal.Event do
        rdate "20090101"
      end
    end

    context "#rdate=" do

      it "should accept a single Date and replace the existing rdate" do
        @event.rdate = Date.parse("20090102")
        @event.rdate.should == [[Date.parse("20090102")]]
      end

      it "should accept a single rfc2445 date format string and replace the existing rdate" do
        @event.rdate = "20090102"
        @event.rdate.should == [[Date.parse("20090102")]]
      end

      it "should accept a single DateTime and replace the existing rdate" do
        @event.rdate = DateTime.parse("20090102T012345")
        @event.rdate.should == [[DateTime.parse("20090102T012345")]]
      end

      it "should accept a single Time and replace the existing rdate" do
        @event.rdate = Time.local(2009, 1, 2, 1, 23, 45)
        @event.rdate.should == [[DateTime.parse("20090102T012345")]]
      end

      it "should accept a single rfc2445 date-time format string  and replace the existing rdate" do
        @event.rdate = "20090102T012345"
        @event.rdate.should == [[DateTime.parse("20090102T012345")]]
      end

      it "should accept a tzid prefixed rfc2445 date-time format string  and replace the existing rdate" do
        @event.rdate = "TZID=America/New_York:20090102T012345"
        @event.rdate.should == [[DateTime.civil(2009, 1, 2, 1, 23, 45, Rational(-5, 24))]]
      end

    end

  end

  context "comment property methods" do
    before(:each) do
      @event = RiCal.Event
      @event.comment = "Comment"
    end

    context "#comment=" do
      it "should result in a single comment for the event" do
        @event.comment.should == ["Comment"]
      end

      it "should replace existing comments" do
        @event.comment = "Replacement"
        @event.comment.should == ["Replacement"]
      end
    end

    context "#comments=" do
      it "should result in a multiple comments for the event replacing existing comments" do
        @event.comments = "New1", "New2"
        @event.comment.should == ["New1", "New2"]
      end
    end

    context "#add_comment" do
      it "should add a single comment" do
        @event.add_comment "New1"
        @event.comment.should == ["Comment", "New1"]
      end
    end

    context "#add_comments" do
      it "should add multiple comments" do
        @event.add_comments "New1", "New2"
        @event.comment.should == ["Comment", "New1", "New2"]
      end
    end

    context "#remove_comment" do
      it "should remove a single comment" do
        @event.add_comment "New1"
        @event.remove_comment "Comment"
        @event.comment.should == ["New1"]
      end
    end

    context "#remove_comments" do
      it "should remove multiple comments" do
        @event.add_comments "New1", "New2", "New3"
        @event.remove_comments "New2", "Comment"
        @event.comment.should == ["New1", "New3"]
      end
    end
  end

  context ".dtstart=" do
    before(:each) do
      @event = RiCal.Event
    end

    context "with a datetime only string" do
      before(:each) do
        @event.dtstart = "20090514T202400"
        @it = @event.dtstart
      end

      it "should interpret it as the correct date-time" do
        @it.should == DateTime.civil(2009, 5, 14, 20, 24, 00, Rational(0,24))
      end

      it "should interpret it as a floating date" do
        @it.tzid.should == :floating
      end
    end

    context "with a TZID and datetime string" do
      before(:each) do
        @event.dtstart = "TZID=America/New_York:20090514T202400"
        @it = @event.dtstart
      end

      it "should interpret it as the correct date-time" do
        @it.should == DateTime.civil(2009, 5, 14, 20, 24, 00, Rational(-5,24))
      end

      it "should set the tzid to America/New_York" do
        @it.tzid.should == "America/New_York"
      end
    end

    context "with a zulu datetime only string" do
      before(:each) do
        @event.dtstart = "20090514T202400Z"
        @it = @event.dtstart
      end

      it "should interpret it as the correct date-time" do
        @it.should == DateTime.civil(2009, 5, 14, 20, 24, 00, Rational(0,24))
      end

      it "should set the tzid to UTC" do
        @it.tzid.should == "UTC"
      end
    end

    context "with a date string" do
      before(:each) do
        @event.dtstart = "20090514"
        @it = @event.dtstart
      end

      it "should interpret it as the correct date-time" do
        @it.should == Date.parse("14 May 2009")
      end
    end
  end

  context ".entity_name" do
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
      @it.dtend_property = "19970101T123456".to_ri_cal_date_time_value
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
      @it.duration_property = "P1H".to_ri_cal_duration_value
      @it.dtend_property.should be_nil
    end

    it "should reset the dtend property if the duration ruby value is set" do
      @it.duration = "P1H".to_ri_cal_duration_value
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