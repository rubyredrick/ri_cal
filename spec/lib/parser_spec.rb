require File.join(File.dirname(__FILE__), %w[.. spec_helper])

require 'lib/parser'
require 'lib/vcalendar'
require 'lib/vevent'
require 'lib/vjournal'
require 'lib/vfreebusy'
require 'lib/vtimezone'
require 'lib/valarm'
require 'lib/v_property'
require 'lib/ext/core_extensions'

describe RiCal::Parser do
  
  def self.describe_property(entity_name, prop_name, params, value, type = RiCal::VTextProperty)
    describe_named_property(entity_name, prop_name, prop_name, params, value, type)
  end
    
  def self.describe_named_property(entity_name, prop_text, prop_name, params, value, type = RiCal::VTextProperty)
    ruby_prop_name = prop_name.tr("-", "_")
    describe "#{prop_name} with value of #{value.inspect}" do
      parse_input = params.inject("BEGIN:#{entity_name.upcase}\n#{prop_text.upcase}") { |pi, assoc| "#{pi};#{assoc[0]}=#{assoc[1]}"}
      parse_input = "#{parse_input}:#{value.to_rfc2445_string}\nEND:#{entity_name.upcase}"
      
      it "should parse an event with an #{prop_text.upcase} property" do
        lambda {RiCal::Parser.parse(StringIO.new(parse_input))}.should_not raise_error
      end

      describe "property characteristics" do
        before(:each) do
          @entity = RiCal::Parser.parse(StringIO.new(parse_input))
          @prop = @entity.send("#{ruby_prop_name.downcase}_property".to_sym)
        end

        it "should be a #{type.name}" do
          @prop.class.should == type
        end

        it "should have the right name" do
          @prop.name.should == prop_text.upcase
        end

        it "should have the right value" do
          @prop.value.should == value
        end
        
        it "should make the value accessible directly" do
          @entity.send(ruby_prop_name.downcase).should == value
        end

        it "should have the right parameters" do
          @prop.params.should == params
        end
      end

    end
  end
  
  describe ".next_line" do
    it "should return line by line" do
      RiCal::Parser.new(StringIO.new("abc\ndef")).next_line.should == "abc"      
    end

    it "should combine lines" do
      RiCal::Parser.new(StringIO.new("abc\n  def\n     ghi")).next_line.should == "abcdefghi"      
    end
  end

  describe ".separate_line" do

    before(:each) do
      @parser = RiCal::Parser.new
    end

    it "should return a hash" do
      @parser.separate_line("abc;x=y;z=1,2:value").should be_kind_of(Hash)
    end

    it "should find the name" do
      @parser.separate_line("abc;x=y;z=1,2:value")[:name].should == "abc"
    end

    it "should find the parameters" do
      @parser.separate_line("abc;x=y;z=1,2:value")[:params].should == {"x" => "y","z" => "1,2"}
    end

    it "should find the value" do
      @parser.separate_line("abc;x=y;z=1,2:value")[:value].should == "value"
    end
  end

  describe ".parse" do

    it "should reject a file which doesn't start with BEGIN" do
      parser = RiCal::Parser.new(StringIO.new("END:VCALENDAR"))
      lambda {parser.parse}.should raise_error     
    end

    describe "parsing an event" do
      it "should parse an event" do
        parser = RiCal::Parser.new(StringIO.new("BEGIN:VEVENT"))
        RiCal::Vevent.should_receive(:from_parser).with(parser)
        parser.parse
      end

      it "should parse an event and return a Vevent" do
        cal = RiCal::Parser.parse(StringIO.new("BEGIN:VEVENT\nEND:VEVENT"))
        cal.should be_kind_of(RiCal::Vevent)
      end

      #RFC 2445 section 4.8.1.1 pp 77
      describe_property("VEVENT", "ATTACH", {"FMTTYPE" => "application/postscript"}, "FMTTYPE=application/postscript:ftp//xyzCorp.com/put/reports/r-960812.ps")

      #RFC 2445 section 4.8.1.2 pp 78
      describe_property("VEVENT", "CATEGORIES", {"LANGUAGE" => "us-EN"}, %w{APPOINTMENT EDUCATION}, RiCal::VArrayProperty)

      #RFC 2445 section 4.8.1.3 pp 79
      describe_named_property("VEVENT", "CLASS", "security_class", {"X-FOO" => "BAR"}, "PUBLIC")

      #RFC 2445 section 4.8.1.4 pp 80
      describe_property("VEVENT", "COMMENT", {"X-FOO" => "BAR"}, "Event comment")

      #RFC 2445 section 4.8.1.5 pp 81
      describe_property("VEVENT", "DESCRIPTION", {"X-FOO" => "BAR"}, "Event description")
      
      #RFC 2445 section 4.8.1.6 pp 82
      describe_property("VEVENT", "GEO", {"X-FOO" => "BAR"}, "37.386013;-122.082932")
      
      #RFC 2445 section 4.8.1.7 pp 84
      describe_property("VEVENT", "LOCATION", {"ALTREP" => "\"http://xyzcorp.com/conf-rooms/f123.vcf\""}, "Conference Room - F123, Bldg. 002")
      
      #RFC 2445 section 4.8.1.8 PERCENT-COMPLETE does not apply to VEvents
      
      #RFC 2445 section 4.8.1.9 pp 84
      describe_property("VEVENT", "PRIORITY", {"X-FOO" => "BAR"}, 1, RiCal::VIntegerProperty)

      #RFC 2445 section 4.8.1.10 pp 87
      describe_property("VEVENT", "RESOURCES", {"X-FOO" => "BAR"}, %w{Easel Projector VCR}, RiCal::VArrayProperty)

      #RFC 2445 section 4.8.1.11 pp 88
      describe_property("VEVENT", "STATUS", {"X-FOO" => "BAR"}, "CONFIRMED")

      #RFC 2445 section 4.8.1.12 pp 89
      describe_property("VEVENT", "SUMMARY", {"X-FOO" => "BAR"}, "Department Party")
      
      #RFC 2445 section 4.8.2.1 COMPLETED does not apply to VEvents
      
      #RFC 2445 section 4.8.2.2 DTEND p91
      describe_property("VEVENT", "DTEND", {"X-FOO" => "BAR"}, "19970714", RiCal::VDateProperty)
      describe_property("VEVENT", "DTEND", {"X-FOO" => "BAR"}, "19970714T235959Z", RiCal::VDateTimeProperty)

      #RFC 2445 section 4.8.2.3 DUE does not apply to VEvents
      
      #RFC 2445 section 4.8.2.4 DTSTART p93
      describe_property("VEVENT", "DTSTART", {"X-FOO" => "BAR"}, "19970714", RiCal::VDateProperty)
      describe_property("VEVENT", "DTSTART", {"X-FOO" => "BAR"}, "19970714T235959Z", RiCal::VDateTimeProperty)

      #RFC 2445 section 4.8.2.5 DURATION p94
      describe_property("VEVENT", "DURATION", {"X-FOO" => "BAR"}, "19970714", RiCal::VDurationProperty)

      #RFC 2445 section 4.8.2.6 FREEBUSY does not apply to VEvents
      
      #RFC 2445 section 4.8.2.4 TRANSP p93
      describe_property("VEVENT", "TRANSP", {"X-FOO" => "BAR"}, "OPAQUE")
      #TO-DO need to spec that values are constrained to OPAQUE and TRANSPARENT
      #      and that this property can be specified at most once
      
      #RFC 2445 section 4.8.4.1 ATTENDEE p102
      describe_property("VEVENT", "ATTENDEE", {"X-FOO" => "BAR"}, "MAILTO:jane_doe@host.com", RiCal::VCalAddressProperty)
      #TO-DO need to handle param values
      
      #RFC 2445 section 4.8.4.2 CONTACT p104
      describe_property("VEVENT", "CONTACT", {"X-FOO" => "BAR"}, "Contact info")
      
      #RFC 2445 section 4.8.4.3 ORGANIZER p106
      describe_property("VEVENT", "ORGANIZER", {"X-FOO" => "BAR", "CN" => "John Smith"}, "MAILTO:jsmith@host1.com", RiCal::VCalAddressProperty)
      #TO-DO need to handle param values     
      
      #RFC 2445 section 4.8.4.4 RECURRENCE-ID p107
      describe_property("VEVENT", "RECURRENCE-ID", {"X-FOO" => "BAR", "VALUE" => "DATE"}, "19970714", RiCal::VDateProperty)
      describe_property("VEVENT", "RECURRENCE-ID", {"X-FOO" => "BAR", "VALUE" => "DATE-TIME"}, "19970714T235959Z", RiCal::VDateTimeProperty)
      #TO-DO need to handle parameters
      
      #RFC 2445 section 4.8.4.5 RELATED-TO p109
      describe_property("VEVENT", "RELATED-TO", {"X-FOO" => "BAR"}, "<jsmith.part7.19960817T083000.xyzMail@host3.com")
      
      #RFC 2445 section 4.8.4.6 URL p110
      describe_property("VEVENT", "URL", {"X-FOO" => "BAR"}, "http://abc.com/pub/calendars/jsmith/mytime.ics", RiCal::VUriProperty)
      
      #RFC 2445 section 4.8.4.7 UID p111
      describe_property("VEVENT", "UID", {"X-FOO" => "BAR"}, "19960401T080045Z-4000F192713-0052@host1.com")
            
      #RFC 2445 section 4.8.5.1 EXDATE p112
      describe_property("VEVENT", "EXDATE", {"X-FOO" => "BAR"}, %w{19960402T010000Z 19960403T010000Z 19960404T010000Z}, RiCal::VDateListProperty)

      #RFC 2445 section 4.8.5.2 EXRULE p114
      describe_property("VEVENT", "EXRULE", {"X-FOO" => "BAR"}, "FREQ=DAILY;COUNT=10", RiCal::VRecurrenceRuleProperty)

      #RFC 2445 section 4.8.5.3 RDATE p115
      describe_property("VEVENT", "RDATE", {"X-FOO" => "BAR"}, %w{19960402T010000Z 19960403T010000Z 19960404T010000Z}, RiCal::VDateListProperty)

      #RFC 2445 section 4.8.5.2 RRULE p117
      describe_property("VEVENT", "RRULE", {"X-FOO" => "BAR"}, "FREQ=DAILY;COUNT=10", RiCal::VRecurrenceRuleProperty)

      #RFC 2445 section 4.8.7.1 CREATED p129
      describe_property("VEVENT", "CREATED", {"X-FOO" => "BAR"}, "19960329T133000Z", RiCal::VDateTimeProperty)
 
      #RFC 2445 section 4.8.7.2 DTSTAMP p129
      describe_property("VEVENT", "DTSTAMP", {"X-FOO" => "BAR"}, "19971210T080000Z", RiCal::VDateTimeProperty)

      #RFC 2445 section 4.8.7.3 LAST-MODIFIED p131
      describe_property("VEVENT", "LAST-MODIFIED", {"X-FOO" => "BAR"}, "19960817T133000Z", RiCal::VDateTimeProperty)

      #RFC 2445 section 4.8.7.3 SEQUENCE p131
      describe_property("VEVENT", "SEQUENCE", {"X-FOO" => "BAR"}, 2, RiCal::VIntegerProperty)

      #RFC 2445 section 4.8.8.2 REQUEST-STATUS p131
      describe_property("VEVENT", "REQUEST-STATUS", {"X-FOO" => "BAR"}, "2.0;Success")
   end

    describe "parsing a calendar" do

      it "should parse a calendar" do
        parser = RiCal::Parser.new(StringIO.new("BEGIN:VCALENDAR"))
        RiCal::Vcalendar.should_receive(:from_parser).with(parser)
        parser.parse
      end

      it "should parse a calendar and return a Vcalendar" do
        cal = RiCal::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nEND:VCALENDAR"))
        cal.should be_kind_of(RiCal::Vcalendar)
      end

      # RFC 2445, section 4.6 section 4.7.1, pp 73-74
      describe_property("VCALENDAR", "CALSCALE", {"X-FOO" => "Y"}, "GREGORIAN")

      # RFC 2445, section 4.6  section 4.7.2, pp 74-75
      describe_property("VCALENDAR", "METHOD", {"X-FOO" => "Y"}, "REQUEST")

      # RFC 2445, section 4.6, pp 51-52, section 4.7.3, p 75-76
      describe_property("VCALENDAR", "PRODID", {"X-FOO" => "Y"}, "-//ABC CORPORATION//NONSGML/ My Product//EN")

      # RFC 2445, section 4.6, pp 51-52, section 4.7.3, p 75-76
      describe_property("VCALENDAR", "VERSION", {"X-FOO" => "Y"}, "2.0")


      # RFC2445 p 51
      it "should parse a calendar with an X property" do
        lambda {RiCal::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nX-PROP;X-FOO=Y:BAR\nEND:VCALENDAR"))}.should_not raise_error
      end

      describe 'the X property' do
        before(:each) do
          @x_props = RiCal::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nX-PROP;X-FOO=Y:BAR\nEND:VCALENDAR")).x_properties
          @x_prop = @x_props["X-PROP"]
        end 

        it "should be a VTextProperty" do
          @x_prop.should be_kind_of(RiCal::VTextProperty)
        end

        it "should have the right name" do
          @x_prop.name.should == "X-PROP"
        end

        it "should have the right value" do
          @x_prop.value.should == "BAR"
        end

        it "should have the right parameters" do
          @x_prop.params.should == {"X-FOO" => "Y"}
        end
      end 
    end

    it "should parse a to-do" do
      parser = RiCal::Parser.new(StringIO.new("BEGIN:VTODO"))
      RiCal::Vtodo.should_receive(:from_parser).with(parser)
      parser.parse
    end

    it "should parse a journal entry" do
      parser = RiCal::Parser.new(StringIO.new("BEGIN:VJOURNAL"))
      RiCal::Vjournal.should_receive(:from_parser).with(parser)
      parser.parse
    end

    it "should parse a free/busy component" do
      parser = RiCal::Parser.new(StringIO.new("BEGIN:VFREEBUSY"))
      RiCal::Vfreebusy.should_receive(:from_parser).with(parser)
      parser.parse
    end

    it "should parse a timezone component" do
      parser = RiCal::Parser.new(StringIO.new("BEGIN:VTIMEZONE"))
      RiCal::Vtimezone.should_receive(:from_parser).with(parser)
      parser.parse
    end

    it "should parse an alarm component" do
      parser = RiCal::Parser.new(StringIO.new("BEGIN:VALARM"))
      RiCal::Valarm.should_receive(:from_parser).with(parser)
      parser.parse
    end
  end
end
