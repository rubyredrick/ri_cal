require File.join(File.dirname(__FILE__), %w[spec_helper])

require 'lib/parser'
require 'lib/vcalendar'
require 'lib/vevent'
require 'lib/vjournal'
require 'lib/vfreebusy'
require 'lib/vtimezone'
require 'lib/valarm'
require 'lib/vtextproperty'

describe Rfc2445::Parser do
  
  def self.describe_property(entity_name, prop_name, params, value, type = Rfc2445::VTextProperty)
    describe prop_name do
      parse_input = params.inject("BEGIN:#{entity_name.upcase}\n#{prop_name.upcase}") { |pi, assoc| "#{pi};#{assoc[0]}=#{assoc[1]}"}
      parse_input = "#{parse_input}:#{value}\nEND:#{entity_name.upcase}"
      
      puts parse_input

      it "should parse an event with an #{prop_name.upcase} property" do
        lambda {Rfc2445::Parser.parse(StringIO.new(parse_input))}.should_not raise_error
      end

      describe "property characteristics" do
        before(:each) do
          @prop = Rfc2445::Parser.parse(StringIO.new(parse_input)).send("#{prop_name.downcase}_property".to_sym)
        end

        it "should be a #{type.name}" do
          @prop.should be_kind_of(type)
        end

        it "should have the right name" do
          @prop.name.should == prop_name.upcase
        end

        it "should have the right value" do
          @prop.value.should == value
        end

        it "should have the right parameters" do
          @prop.params.should == params
        end
      end

    end
  end
  
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
      @parser.separate_line("abc;x=y;z=1,2:value")[:params].should == {"x" => "y","z" => "1,2"}
    end

    it "should find the value" do
      @parser.separate_line("abc;x=y;z=1,2:value")[:value].should == "value"
    end
  end

  describe ".parse" do

    it "should reject a file which doesn't start with BEGIN" do
      parser = Rfc2445::Parser.new(StringIO.new("END:VCALENDAR"))
      lambda {parser.parse}.should raise_error     
    end

    describe "parsing an event" do
      it "should parse an event" do
        parser = Rfc2445::Parser.new(StringIO.new("BEGIN:VEVENT"))
        Rfc2445::Vevent.should_receive(:from_parser).with(parser)
        parser.parse
      end

      it "should parse an event and return a Vevent" do
        cal = Rfc2445::Parser.parse(StringIO.new("BEGIN:VEVENT\nEND:VEVENT"))
        cal.should be_kind_of(Rfc2445::Vevent)
      end

      #RFC 2445 section 4.8.1.1 pp 77
      describe_property("VEVENT", "ATTACH", {"FMTTYPE" => "application/postscript"}, "FMTTYPE=application/postscript:ftp//xyzCorp.com/put/reports/r-960812.ps")


      #RFC 2445 section 4.8.1.2 pp 77
      describe_property("VEVENT", "CATEGORIES", {"LANGUAGE" => "us-EN"}, "APPOINTMENT,EDUCATION")
    end

    describe "parsing a calendar" do

      it "should parse a calendar" do
        parser = Rfc2445::Parser.new(StringIO.new("BEGIN:VCALENDAR"))
        Rfc2445::Vcalendar.should_receive(:from_parser).with(parser)
        parser.parse
      end

      it "should parse a calendar and return a Vcalendar" do
        cal = Rfc2445::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nEND:VCALENDAR"))
        cal.should be_kind_of(Rfc2445::Vcalendar)
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
        lambda {Rfc2445::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nX-PROP;X-FOO=Y:BAR\nEND:VCALENDAR"))}.should_not raise_error
      end

      describe 'the X property' do
        before(:each) do
          @x_props = Rfc2445::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nX-PROP;X-FOO=Y:BAR\nEND:VCALENDAR")).x_properties
          @x_prop = @x_props["X-PROP"]
        end 

        it "should be a VTextProperty" do
          @x_prop.should be_kind_of(Rfc2445::VTextProperty)
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
