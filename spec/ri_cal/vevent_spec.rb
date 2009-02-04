require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::Vevent do

  describe "with both dtend and duration specified" do
    before(:each) do
      @it = RiCal::Vevent.parse_string("BEGIN:VEVENT\nDTEND:19970903T190000Z\nDURATION:H1\nEND:VEVENT").first
    end
    
    it "should be invalid" do
      @it.should_not be_valid
    end
  end

  describe "with a duration property" do
    before(:each) do
      @it = RiCal::Vevent.parse_string("BEGIN:VEVENT\nDURATION:H1\nEND:VEVENT").first
    end

    it "should have a duration property" do
      @it.duration_property.should be
    end
    
    it "should have a duration of 1 Hour" do
      @it.duration_property.value.should == "H1"
    end
    
    it "should reset the duration property if the dtend property is set" do
      @it.dtend_property = "19970101".to_ri_cal_date_time_value
      @it.duration_property.should be_nil
    end
    
    it "should reset the duration property if the dtend ruby value is set" do
      @it.dtend = "19970101"
      @it.duration_property.should == nil
    end
  end

  describe "with a dtend property" do
    before(:each) do
      @it = RiCal::Vevent.parse_string("BEGIN:VEVENT\nDTEND:19970903T190000Z\nEND:VEVENT").first
    end

    it "should have a duration property" do
      @it.dtend_property.should be
    end
    
    it "should reset the dtend property if the duration property is set" do
      @it.duration_property = "H1".to_ri_cal_duration_value
      @it.dtend_property.should be_nil
    end
    
    it "should reset the dtend property if the duration ruby value is set" do
      @it.duration = "H1".to_ri_cal_duration_value
      @it.dtend_property.should be_nil
    end
  end
end