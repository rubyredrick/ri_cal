require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::PropertyValue do
  
  describe ".initialize" do
    
    it "should reject a value starting with ';'" do
      lambda {RiCal::PropertyValue.new(nil, :value => ";bogus")}.should raise_error {|err| err.message.should == "Invalid property value \";bogus\""}
    end
  end

  describe "#date_or_date_time" do

    it "should raise an exception on an invalid date" do
      lambda {RiCal::PropertyValue.date_or_date_time(nil, :value => "foo")}.should raise_error
    end 
    
    
    describe "rfc 2445 section 4.3.4 p 34" do
      before(:each) do
        @prop = RiCal::PropertyValue.date_or_date_time(nil, :value => "19970714")
      end

      it "should return a PropertyValue::Date" do
        @prop.should be_kind_of(RiCal::PropertyValue::Date)
      end
      
      it "should set the correct date" do
        @prop.to_ri_cal_ruby_value.should == Date.parse("Jul 14, 1997")
      end  
    end
    
    describe "rfc 2445 section 4.3.5 p 35" do
      describe "FORM #1 date with local time p 36" do
        before(:each) do
          @prop = RiCal::PropertyValue.date_or_date_time(nil, :value => "19970714T123456")
        end

        it "should return a PropertyValue::DateTime" do
          @prop.should be_kind_of(RiCal::PropertyValue::DateTime)
        end
        
        it "should have the right ruby value" do
          @prop.to_ri_cal_ruby_value.should == DateTime.parse("19970714T123456")
        end
        
        it "should have the right value" do
          @prop.value.should == "19970714T123456"
        end
        
        it "should have a nil tzid" do
          @prop.tzid.should be_nil
        end
      end
      
      describe "FORM #2 date with UTC time p 36" do
        before(:each) do
          @prop = RiCal::PropertyValue.date_or_date_time(nil, :value => "19970714T123456Z")
        end

        it "should return a PropertyValue::DateTime" do
          @prop.should be_kind_of(RiCal::PropertyValue::DateTime)
        end
        
        it "should have the right value" do
          @prop.value.should == "19970714T123456Z"
        end
        
        it "should have the right ruby value" do
          @prop.to_ri_cal_ruby_value.should == DateTime.parse("19970714T123456Z")
        end
        
        it "should have a tzid of UTC" do
          @prop.tzid.should == "UTC"
        end
        
      end
      
      describe "FORM #3 date with local time and time zone reference p 36" do
        before(:each) do
          @prop = RiCal::PropertyValue.date_or_date_time(nil, :value => "19970714T123456", :params => {'TZID' => 'US-Eastern'})
        end

        it "should return a PropertyValue::DateTime" do
          @prop.should be_kind_of(RiCal::PropertyValue::DateTime)
        end
        
        it "should have the right value" do
          @prop.value.should == "19970714T123456"
        end
        
        it "should have the right ruby value" do
          #TODO - what do we do about timezone with and without activesupport
          @prop.to_ri_cal_ruby_value.should == DateTime.parse("19970714T123456")
        end
        
        it "should have the right tzid" do
          @prop.tzid.should == "US-Eastern"
        end
        
        it "should raise an error if combined with a zulu time" do
          lambda {RiCal::PropertyValue.date_or_date_time(nil, :value => "19970714T123456Z", :params => {:tzid => 'US-Eastern'})}.should raise_error
        end  
      end
    end
    
  end
end