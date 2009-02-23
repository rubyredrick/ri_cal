require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'date'

describe RiCal::DurationValue do
  
  describe "with various values" do
    def value_expectations(dv, values = {})
      values = {:weeks => 0, :days => 0, :hours => 0, :minutes => 0, :seconds => 0}.merge(values)
      dv.weeks.should == values[:weeks]
      dv.days.should == values[:days]
      dv.hours.should == values[:hours]
      dv.minutes.should == values[:minutes]
      dv.seconds.should == values[:seconds]
    end
    
    it ".+P7W should have represent 7 weeks" do
      value_expectations(RiCal::DurationValue.new(:value => "+P7W"), :weeks => 7)
    end
    
    it ".P15DT5H0M20S should have represent 15 days, 5 hours and 20 seconds" do
      value_expectations(RiCal::DurationValue.new(:value => "P15DT5H0M20S"), :days => 15, :hours => 5, :seconds => 20)
    end
    
    it ".+P2D should have represent 2 days" do
      value_expectations(RiCal::DurationValue.new(:value => "+P2D"), :days => 2)
    end
    
    it ".+PT3H should have represent 3 hours" do
      value_expectations(RiCal::DurationValue.new(:value => "+PT3H"), :hours => 3)
    end
    
    it ".+PT15M should have represent 15 minutes" do
      value_expectations(RiCal::DurationValue.new(:value => "+PT15M"), :minutes => 15)
    end
    
    it ".+PT45S should have represent 45 seconds" do
      value_expectations(RiCal::DurationValue.new(:value => "+PT45S"), :seconds => 45)
    end
  end
  
  describe ".from_datetimes" do
    
    describe "starting at 11:00 pm, and ending at 1:01:02 am the next day" do
      before(:each) do
        @it = RiCal::DurationValue.from_datetimes(
                      DateTime.parse("9/1/2008 23:00"), 
                      DateTime.parse("9/2/2008 1:01:02")
                  ) 
      end

      it "should produce a duration" do
        @it.class.should == RiCal::DurationValue
      end
      
      it "should have a value of '+P2H1M2S'" do
        @it.value.should == '+PT2H1M2S'
      end
      
      it "should contain zero days" do
        @it.days.should == 0
      end
      
      it "should contain two hours" do
        @it.hours.should == 2
      end
      
      it "should contain one minute" do
        @it.minutes.should == 1
      end
      
      it "should contain one minute" do
        @it.minutes.should == 1
      end
    end
  end
  
end