#- c2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license

require 'spec_helper'

describe RiCal::Component::Freebusy do
  
  describe ".entity_name" do
    it "should be VFREEBUSY" do
      RiCal::Component::Freebusy.entity_name.should == "VFREEBUSY"
    end
  end
end