require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::Freebusy do
  
  describe ".entity_name" do
    it "should be VFREEBUSY" do
      RiCal::Freebusy.entity_name.should == "VFREEBUSY"
    end
  end
end