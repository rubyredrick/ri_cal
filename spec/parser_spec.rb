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

      # RFC 2445, section 4.6
      it "should parse a calendar with a CALSCALE property" do
        lambda {Rfc2445::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nCALSCALE;X-FOO=Y:GREGORIAN\nEND:VCALENDAR"))}.should_not raise_error
      end

      # RFC 2445 section 4.7.1, pp 73-74
      describe 'the CALSCALE property' do
        before(:each) do
          @calscale_prop = Rfc2445::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nCALSCALE;X-FOO=Y:GREGORIAN\nEND:VCALENDAR")).calscale_property
        end 

        it "should be a VTextProperty" do
          @calscale_prop.should be_kind_of(Rfc2445::VTextProperty)
        end

        it "should have the right name" do
          @calscale_prop.name.should == "CALSCALE"
        end

        it "should have the right value" do
          @calscale_prop.value.should == "GREGORIAN"
        end

        it "should have the right parameters" do
          @calscale_prop.params.should == {"X-FOO" => "Y"}
        end
      end

      # RFC 2445, section 4.6
      it "should parse a calendar with a METHOD property" do
        lambda {Rfc2445::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nMETHOD;X-FOO=Y:REQUEST\nEND:VCALENDAR"))}.should_not raise_error
      end

      # RFC 2445 section 4.7.2, pp 73-74
      describe 'the METHOD property' do
        before(:each) do
          @method_prop = Rfc2445::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nMETHOD;X-FOO=Y:REQUEST\nEND:VCALENDAR")).method_property
        end 

        it "should be a VTextProperty" do
          @method_prop.should be_kind_of(Rfc2445::VTextProperty)
        end

        it "should have the right name" do
          @method_prop.name.should == "METHOD"
        end

        it "should have the right value" do
          @method_prop.value.should == "REQUEST"
        end

        it "should have the right parameters" do
          @method_prop.params.should == {"X-FOO" => "Y"}
        end
      end

     # RFC 2445, section 4.6, pp 51-52 
      it "should parse a calendar with a PRODID property" do
        lambda {Rfc2445::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nPRODID;X-FOO=Y:-//ABC CORPORATION//NONSGML/ My Product//EN\nEND:VCALENDAR"))}.should_not raise_error
      end

      # RFC 2445, section 4.7.3, p 75-76
      describe 'the PRODID property' do
        before(:each) do
          @prodid_prop = Rfc2445::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nPRODID;X-FOO=Y:-//ABC CORPORATION//NONSGML/ My Product//EN\nEND:VCALENDAR")).prodid_property
        end 

        it "should be a VTextProperty" do
          @prodid_prop.should be_kind_of(Rfc2445::VTextProperty)
        end

        it "should have the right name" do
          @prodid_prop.name.should == "PRODID"
        end

        it "should have the right value" do
          @prodid_prop.value.should == "-//ABC CORPORATION//NONSGML/ My Product//EN"
        end

        it "should have the right parameters" do
          @prodid_prop.params.should == {"X-FOO" => "Y"}
        end
      end

      # RFC 2445, section 4.6, pp 51-52 
       it "should parse a calendar with a VERSION property" do
         lambda {Rfc2445::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nVERSION;X-FOO=Y:2.0\nEND:VCALENDAR"))}.should_not raise_error
       end

       # RFC 2445, section 4.7.3, p 75-76
       describe 'the VERSION property' do
         before(:each) do
           @version_prop = Rfc2445::Parser.parse(StringIO.new("BEGIN:VCALENDAR\nVERSION;X-FOO=Y:2.0\nEND:VCALENDAR")).version_property
         end 

         it "should be a VTextProperty" do
           @version_prop.should be_kind_of(Rfc2445::VTextProperty)
         end

         it "should have the right name" do
           @version_prop.name.should == "VERSION"
         end

         it "should have the right value" do
           @version_prop.value.should == "2.0"
         end

         it "should have the right parameters" do
           @version_prop.params.should == {"X-FOO" => "Y"}
         end
       end


      # RFC2445 p 51, 
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
