#- ©2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license

require File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper])

describe RiCal::CoreExtensions::String::Conversions do
  context "#to_ri_cal_date_time_value" do
    
    it "should produce a DateTime property for a valid RFC 2445 datetime string" do
      "20090304T123456".to_ri_cal_date_time_value.should == RiCal::PropertyValue::DateTime.new(nil, :value => "20090304T123456")
    end
    
    it "should produce a DateTime property for a valid RFC 2445 datetime string with a TZID parameter" do
      "TZID=America/New_York:20090304T123456".to_ri_cal_date_time_value.should == RiCal::PropertyValue::DateTime.new(nil, :params => {"TZID" => "America/New_York"}, :value => "20090304T123456")
    end
    
    it "should raise an InvalidPropertyValue error if the string is not a valid RFC 2445 datetime string" do
      lambda {"20090304".to_ri_cal_date_time_value}.should raise_error(RiCal::InvalidPropertyValue)
    end
  end
end
