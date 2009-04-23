require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::Component do
  
  describe "building blocks" do
    it "should build an Event" do
      @it = RiCal::Component::Event.new do
        description "MA-6 First US Manned Spaceflight"
        dtstart     DateTime.parse("2/20/1962 14:47:39")
        dtend       DateTime.parse("2/20/1962 19:43:02")
        location    "Cape Canaveral"
      end
      rputs @it.to_s
    end
  end
end