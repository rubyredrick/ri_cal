#- ©2009 Rick DeNatale
#- All rights reserved

require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::PropertyValue::OccurrenceList do
  
  context ".convert method" do
    context "with a single datetime" do
      before(:each) do
        @it = RiCal::PropertyValue::OccurrenceList.convert(nil, DateTime.parse("5 May 2009, 9:32 am"))
      end
      
      it "should produce the right ical representation" do
        @it.to_s.should == ":20090505T093200Z"
      end
      
      it "should have the right ruby value" do
        @it.ruby_value.should == [DateTime.parse("5 May 2009, 9:32 am")]
      end
      
      it "should have the right elements" do
        @it.send(:elements).should == [RiCal::PropertyValue::DateTime.new(nil, :value => "20090505T093200Z" )]
      end
    end
    
    context "with a tzid and a single datetime" do
      before(:each) do
        @it = RiCal::PropertyValue::OccurrenceList.convert(nil, ['US/Eastern', DateTime.parse("Feb 20, 1962 14:47:39")])
      end
      
      it "should produce the right ical representation" do
        @it.to_s.should == ";TZID=US/Eastern:19620220T144739"
      end
      
      it "should have the right ruby value" do
        @it.ruby_value.should == [DateTime.parse("Feb 20, 1962 14:47:39")]
      end
      
      it "should have the right elements" do
        @it.send(:elements).should == [RiCal::PropertyValue::DateTime.new(nil, :params=> {'TZID' => 'US/Eastern'}, :value => "19620220T144739" )]
      end
    end
  end 
end