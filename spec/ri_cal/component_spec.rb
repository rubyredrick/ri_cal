require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::Component do

  describe "building blocks" do
    describe "building an event for MA-6" do
      before(:each) do
        @it = RiCal::Component::Event.new do
          description "MA-6 First US Manned Spaceflight"
          dtstart     DateTime.parse("2/20/1962 14:47:39")
          dtend       DateTime.parse("2/20/1962 19:43:02")
          location    "Cape Canaveral"
          add_attendee "john.glenn@nasa.gov"
          alarm do
            description "Segment 51"
          end
        end
      end

      it "should have the right description" do
        @it.description.should == "MA-6 First US Manned Spaceflight"     
      end

      it "should have the right dtstart" do
        @it.dtstart.should == DateTime.parse("2/20/1962 14:47:39")
      end

      it "should have a zulu time dtstart property" do
        @it.dtstart_property.tzid.should == "UTC"
      end

      it "should have the right dtend" do
        @it.dtend.should == DateTime.parse("2/20/1962 19:43:02")
      end

      it "should have a zulu time dtend property" do
        @it.dtend_property.tzid.should == "UTC"
      end

      it "should have the right location" do
        @it.location.should == "Cape Canaveral"
      end

      it "should have the right attendee" do
        @it.attendee.should include("john.glenn@nasa.gov")
      end
      
      it "should have 1 alarm" do
        @it.alarms.length.should == 1
      end
      
      it "should have an alarm with the right description" do
        @it.alarms.first.description.should == "Segment 51"
      end
    end
  end
end