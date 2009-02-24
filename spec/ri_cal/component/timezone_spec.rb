require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::Component::Timezone do
  
  describe ".entity_name" do
    it "should be VTIMEZONE" do
      RiCal::Component::Timezone.entity_name.should == "VTIMEZONE"
    end
  end
end