require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::Journal do
  
  describe ".entity_name" do
    it "should be VJOURNAL" do
      RiCal::Journal.entity_name.should == "VJOURNAL"
    end
  end
end
