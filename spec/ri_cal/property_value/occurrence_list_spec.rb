#- ©2009 Rick DeNatale
#- All rights reserved

require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::PropertyValue::OccurrenceList do
  context "class methods" do
    before(:each) do
      @it = RiCal::PropertyValue::OccurrenceList
      @dt_prop = RiCal::PropertyValue::DateTime
      @d_prop = RiCal::PropertyValue::Date
      @per_prop = RiCal::PropertyValue::Period
    end

    context "self.occurence_list_property_from_string" do
      it "should produce a Date property from 20090101" do
        @it.occurence_list_property_from_string(nil, "20090101").should == @d_prop.new(nil, :value => "20090101")
      end

      it "should produce a DateTime property from 20090507T192200" do
        @it.occurence_list_property_from_string(nil, "20090507T192200").should == @dt_prop.new(nil, :value => "20090507T192200")
      end

      it "should produce a Period property from 20090507T180000/P2H" do
        @it.occurence_list_property_from_string(nil, "20090507T180000/P2H").should == @per_prop.new(nil, :value => "20090507T180000/P2H")
      end
    end
  end
  
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
        timezone = mock("Timezone", :rational_utc_offset => Rational(-5, 24))
        timezone_finder = mock("tz_finder", :find_timezone => timezone, :default_tzid => "UTC")        
        @it = RiCal::PropertyValue::OccurrenceList.convert(timezone_finder, 'US/Eastern', DateTime.parse("Feb 20, 1962 14:47:39"))
      end
      
      it "should produce the right ical representation" do
        @it.to_s.should == ";TZID=US/Eastern:19620220T144739"
      end
      
      context "its ruby value" do

        it "should be the right DateTime" do
          @it.ruby_value.should == [DateTime.civil(1962, 2, 20, 14, 47, 39, Rational(-5, 24))]
        end
        
        it "should have the right tzid" do
          @it.ruby_value.first.tzid.should == "US/Eastern"
        end
      end
      
      it "should have the right elements" do
        @it.send(:elements).should == [RiCal::PropertyValue::DateTime.new(nil, :params=> {'TZID' => 'US/Eastern'}, :value => "19620220T144739" )]
      end
    end
  end 
end