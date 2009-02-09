require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::Alarm do
  
  describe ".entity_name" do
    it "should be VALARM" do
      RiCal::Alarm.entity_name.should == "VALARM"
    end
  end
end
