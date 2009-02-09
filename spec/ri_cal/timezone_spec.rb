require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::Timezone do
  
  describe ".entity_name" do
    it "should be VTIMEZONE" do
      RiCal::Timezone.entity_name.should == "VTIMEZONE"
    end
  end
end