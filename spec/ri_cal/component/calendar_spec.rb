#- ©2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license

require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::Component::Calendar do

  context ".entity_name" do
    it "should be VCALENDAR" do
      RiCal::Component::Calendar.entity_name.should == "VCALENDAR"
    end
  end
  
  context "a new instance" do
    before(:each) do
      @it = RiCal.Calendar
    end
    
    it "should have a tz_source of 'TZ_INFO" do
      @it.tz_source.should == "TZINFO"
    end
    
    it "should export a product id with an X-RICAL-TZSOURCE parameter of TZINFO" do
      @it.export.should match(%r{\nPRODID;X-RICAL-TZSOURCE=TZINFO:-//com.denhaven2/NONSGML ri_cal gem//EN\n})
    end
  end
  
  context "an imported instance with a tzinfo source" do
    before(:each) do
      @it = RiCal.parse_string("BEGIN:VCALENDAR\nPRODID;X-RICAL-TZSOURCE=TZINFO:-\/\/com.denhaven2\/NONSGML ri_cal gem\/\/EN\nCALSCALE:GREGORIAN\nVERSION:2.0\nEND:VCALENDAR\n").first
    end
    
    it "should have a tz_source of 'TZ_INFO" do
      @it.tz_source.should == "TZINFO"
    end
    
    it "should export a product id with an X-RICAL-TZSOURCE parameter of TZINFO" do
      @it.export.should match(%r{\nPRODID;X-RICAL-TZSOURCE=TZINFO:-//com.denhaven2/NONSGML ri_cal gem//EN\n})
    end
  end
  
  context "an imported instance without a tzinfo source" do
    before(:each) do
      @it = RiCal.parse_string("BEGIN:VCALENDAR\nPRODID:-//Apple Inc.//iCal 3.0//EN\nEND:VCALENDAR\n").first
    end
    
    it "should have a tz_source of nil" do
      @it.tz_source.should be_nil
    end
    
    it "should export not export a product id with an X-RICAL-TZSOURCE parameter of TZINFO" do
      @it.export.should_not match(%r{X-RICAL-TZSOURCE=TZINFO:})
    end
  end
end
