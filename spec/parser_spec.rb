require File.join(File.dirname(__FILE__), %w[spec_helper])

require 'lib/parser'
require 'lib/vcalendar'
require 'lib/vevent'
require 'lib/vjournal'
require 'lib/vfreebusy'
require 'lib/vtimezone'
require 'lib/valarm'

describe Rfc2445::Parser do

  describe ".next_line" do
    it "should return line by line" do
      Rfc2445::Parser.new(StringIO.new("abc\ndef")).next_line.should == "abc"      
    end

    it "should combine lines" do
      Rfc2445::Parser.new(StringIO.new("abc\n  def\n     ghi")).next_line.should == "abcdefghi"      
    end
  end

  describe ".separate_line" do

    before(:each) do
      @parser = Rfc2445::Parser.new
    end

    it "should return a hash" do
      @parser.separate_line("abc;x=y;z=1,2:value").should be_kind_of(Hash)
    end

    it "should find the name" do
      @parser.separate_line("abc;x=y;z=1,2:value")[:name].should == "abc"
    end

    it "should find the parameters" do
      @parser.separate_line("abc;x=y;z=1,2:value")[:params].should == ["x=y","z=1,2"]
    end

    it "should find the value" do
      @parser.separate_line("abc;x=y;z=1,2:value")[:value].should == "value"
    end
  end
  
  describe ".parse" do
    #     @input_data = <<ICAL_END
    # BEGIN:VCALENDAR
    # PRODID:-//Apple Inc.//iCal 3.0//EN
    # CALSCALE:GREGORIAN
    # VERSION:2.0
    # METHOD:REQUEST
    # BEGIN:VEVENT
    # SEQUENCE:16
    # DTSTART;TZID=US/Eastern:20081001T090000
    # X-WR-ATTENDEE;CN="Matt Lacny";CUTYPE=INDIVIDUAL;PARTSTAT=NEEDS-ACTION;RO
    #  LE=REQ-PARTICIPANT;RSVP=TRUE:invalid:nomail
    # DTSTAMP:20080930T210941Z
    # SUMMARY:Status Meeting
    # ATTENDEE;CN="Near Time";CUTYPE=INDIVIDUAL;PARTSTAT=NEEDS-ACTION;ROLE
    #  =REQ-PARTICIPANT;RSVP=TRUE:mailto:meetings@near-time.com
    # ATTENDEE;CN="Brent Collier";CUTYPE=INDIVIDUAL;PARTSTAT=NEEDS-ACTION;ROLE
    #  =REQ-PARTICIPANT;RSVP=TRUE:mailto:brent@near-time.com
    # ATTENDEE;CN="Charlie Bowman";CUTYPE=INDIVIDUAL;PARTSTAT=NEEDS-ACTION;ROL
    #  E=REQ-PARTICIPANT;RSVP=TRUE:mailto:charlie@near-time.com
    # DTEND;TZID=US/Eastern:20081001T100000
    # TRANSP:OPAQUE
    # UID:9121E38D-8FB8-4791-B466-8D2AB2B4968A
    # ORGANIZER;CN="Ben Burdick":mailto:ben@near-time.com
    # DESCRIPTION:rescheduled for 9 since kevin can't make 8:30
    # CREATED:20080930T185107Z
    # END:VEVENT
    # END:VCALENDAR
    # ICAL_END
    
    it "should reject a file which doesn't start with BEGIN" do
      parser = Rfc2445::Parser.new(StringIO.new("END:VCALENDAR"))
      lambda {parser.parse}.should raise_error     
    end
    
    it "should parse a calendar" do
      parser = Rfc2445::Parser.new(StringIO.new("BEGIN:VCALENDAR"))
      Rfc2445::Vcalendar.should_receive(:from_parser).with(parser)
      parser.parse
    end
    
    it "should parse a calendar and return a Vcalendar" do
      parser = Rfc2445::Parser.new(StringIO.new("BEGIN:VCALENDAR\nEND:VCALENDAR"))
      parser.parse.should be_kind_of(Rfc2445::Vcalendar)
    end
    
    it "should parse an event" do
      parser = Rfc2445::Parser.new(StringIO.new("BEGIN:VEVENT"))
      Rfc2445::Vevent.should_receive(:from_parser).with(parser)
      parser.parse
    end
    
    it "should parse a to-do" do
      parser = Rfc2445::Parser.new(StringIO.new("BEGIN:VTODO"))
      Rfc2445::Vtodo.should_receive(:from_parser).with(parser)
      parser.parse
    end
    
    it "should parse a journal entry" do
      parser = Rfc2445::Parser.new(StringIO.new("BEGIN:VJOURNAL"))
      Rfc2445::Vjournal.should_receive(:from_parser).with(parser)
      parser.parse
    end
    
    it "should parse a free/busy component" do
      parser = Rfc2445::Parser.new(StringIO.new("BEGIN:VFREEBUSY"))
      Rfc2445::Vfreebusy.should_receive(:from_parser).with(parser)
      parser.parse
    end
    
    it "should parse a timezone component" do
      parser = Rfc2445::Parser.new(StringIO.new("BEGIN:VTIMEZONE"))
      Rfc2445::Vtimezone.should_receive(:from_parser).with(parser)
      parser.parse
    end
    
    it "should parse an alarm component" do
      parser = Rfc2445::Parser.new(StringIO.new("BEGIN:VALARM"))
      Rfc2445::Valarm.should_receive(:from_parser).with(parser)
      parser.parse
    end
  end
end
