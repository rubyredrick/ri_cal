#- ©2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license

require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe RiCal::Component::Todo do

  describe "with both due and duration specified" do
    before(:each) do
      @it = RiCal::Component::Todo.parse_string("BEGIN:VTODO\nDUE:19970903T190000Z\nDURATION:H1\nEND:VTODO").first
    end
    
    it "should be invalid" do
      @it.should_not be_valid
    end
  end

  describe "with a duration property" do
    before(:each) do
      @it = RiCal::Component::Todo.parse_string("BEGIN:VTODO\nDURATION:H1\nEND:VTODO").first
    end

    it "should have a duration property" do
      @it.duration_property.should be
    end
    
    it "should have a duration of 1 Hour" do
      @it.duration_property.value.should == "H1"
    end
    
    it "should reset the duration property if the due property is set" do
      @it.due_property = "19970101T012345".to_ri_cal_date_time_value
      @it.duration_property.should be_nil
    end
    
    it "should reset the duration property if the dtend ruby value is set" do
      @it.due = "19970101"
      @it.duration_property.should == nil
    end
  end

  describe "with a due property" do
    before(:each) do
      @it = RiCal::Component::Todo.parse_string("BEGIN:VTODO\nDUE:19970903T190000Z\nEND:VTODO").first
    end

    it "should have a due property" do
      @it.due_property.should be
    end
    
    it "should reset the due property if the duration property is set" do
      @it.duration_property = "P1H".to_ri_cal_duration_value
      @it.due_property.should be_nil
    end
    
    it "should reset the duration property if the dtend ruby value is set" do
      @it.duration = "P1H"
      @it.due_property.should == nil
    end
  end
end