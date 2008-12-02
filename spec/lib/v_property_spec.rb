require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require File.join(File.dirname(__FILE__), %w[.. .. lib v_property])

describe RiCal::VProperty do

  describe "#date_or_date_time" do

    it "should raise an exception on an invalid date" do
      lambda {RiCal::VProperty.date_or_date_time(:value => "foo")}.should raise_error
    end 
    
    
    describe "rfc 2445 section 4.3.4 p 34" do
      before(:each) do
        @prop = RiCal::VProperty.date_or_date_time(:value => "19970714")
      end

      it "should return a VDateProperty" do
        @prop.should be_kind_of(RiCal::VDateProperty)
      end
      
      it "should set the correct date" do
        @prop.value.should == Date.parse("Jul 14, 1997")
      end  
    end
    
    describe "rfc 2445 section 4.3.5 p 35" do
      describe "FORM #1 date with local time p 36" do
        before(:each) do
          @prop = RiCal::VProperty.date_or_date_time(:value => "19970714T123456")
        end

        it "should return a VDateTimeProperty" do
          @prop.should be_kind_of(RiCal::VDateTimeProperty)
        end
        
        it "should have the right value" do
          @prop.value.should == Time.utc(1997, 7, 14, 12, 34, 56)
        end
        
        it "should have a nil tzid" do
          @prop.tzid.should be_nil
        end
      end
      
      describe "FORM #2 date with UTC time p 36" do
        before(:each) do
          @prop = RiCal::VProperty.date_or_date_time(:value => "19970714T123456Z")
        end

        it "should return a VDateTimeProperty" do
          @prop.should be_kind_of(RiCal::VDateTimeProperty)
        end
        
        it "should have the right value" do
          @prop.value.should == Time.utc(1997, 7, 14, 12, 34, 56)
        end
        
        it "should have a tzid of UTC" do
          @prop.tzid.should == "UTC"
        end
        
      end
      
      describe "FORM #3 date with local time and time zone reference p 36" do
        before(:each) do
          @prop = RiCal::VProperty.date_or_date_time(:value => "19970714T123456", :params => {:tzid => 'US-Eastern'})
        end

        it "should return a VDateTimeProperty" do
          @prop.should be_kind_of(RiCal::VDateTimeProperty)
        end
        
        it "should have the right value" do
          @prop.value.should == Time.utc(1997, 7, 14, 12, 34, 56)
        end
        
        it "should have the right tzid" do
          @prop.tzid.should == "US-Eastern"
        end
        
        it "should raise an error if combined with a zulu time" do
          lambda {RiCal::VProperty.date_or_date_time(:value => "19970714T123456Z", :params => {:tzid => 'US-Eastern'})}.should raise_error
        end  
      end
    end
    
  end
end