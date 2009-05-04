#- ©2009 Rick DeNatale
#- All rights reserved

require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::Component::Journal do
  
  describe ".entity_name" do
    it "should be VJOURNAL" do
      RiCal::Component::Journal.entity_name.should == "VJOURNAL"
    end
  end
end
