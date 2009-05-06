#- ©2009 Rick DeNatale
#- All rights reserved

require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::PropertyValue::OccurrenceList do
  
  context ".convert method" do
    context "with a single datetime" do
      before(:each) do
        @it = RiCal::PropertyValue::OccurrenceList.convert(nil, DateTime.parse("5 May 2009, 9:32 am"))
      end
      
      it "should produce the right value" do
        pending
        @it.value.should == ""
      end
    end
  end 
end