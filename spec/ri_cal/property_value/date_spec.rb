#- ©2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license

require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::PropertyValue::Date do
  describe ".advance" do
    it "should advance by one week if passed :days => 7" do
      dt1 = RiCal::PropertyValue::Date.new(nil, :value => "20050131")
      dt2 = RiCal::PropertyValue::Date.new(nil, :value => "20050207")
      dt1.advance(:days => 7).should == dt2
    end
    
    describe ".==" do
      it "should return true for two instances representing the same date" do
        dt1 = RiCal::PropertyValue::Date.new(nil, :value => DateTime.parse("20050131T010000"))
        dt2 = RiCal::PropertyValue::Date.new(nil, :value => DateTime.parse("20050131T010001"))
        dt1.should == dt2        
      end
    end
  end
end