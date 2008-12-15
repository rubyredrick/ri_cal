require File.join(File.dirname(__FILE__), %w[.. spec_helper])

require 'lib/recurrence_rule'

# rfc 2445 4.3.10 p.40
describe RiCal::RecurrenceRule do
  
  describe "initialized from hash" do
    it "should require a frequency" do
      @it = RiCal::RecurrenceRule.new({})
      @it.errors.should include("RecurrenceRule must have a value for FREQ")
    end
    
    it "accept reject an invalid frequency" do
      @it = RiCal::RecurrenceRule.new(:freq => "blort")
      @it.should_not be_valid      
      @it.errors.should include("Invalid frequency 'blort'")
    end
    
    %w{secondly SECONDLY minutely MINUTELY hourly HOURLY daily DAILY weekly WEEKLY monthly MONTHLY
      yearly YEARLY
      }.each do | freq_val |
        it "should accept a frequency of #{freq_val}" do
          RiCal::RecurrenceRule.new(:freq => freq_val).should be_valid               
        end
      end
    
    it "should reject setting both until and count" do
      @it = RiCal::RecurrenceRule.new(:freq => "daily", :until => Time.now, :count => 10)
      @it.should_not be_valid            
      @it.errors.should include("COUNT and UNTIL cannot both be specified")
    end
    
    describe "interval parameter" do 
      
      # p 42
      it "should default to 1" do
        RiCal::RecurrenceRule.new(:freq => "daily").interval.should == 1
      end 
      
      it "should accept an explicit value" do
        RiCal::RecurrenceRule.new(:freq => "daily", :interval => 42).interval.should == 42
      end
      
      it "should reject a negative value" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :interval => -1)
        @it.should_not be_valid
      end
    end
    
    describe "by_second parameter" do

      it "should accept a single integer" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_second => 10)
        @it.send(:by_list)[:by_second].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_second => [10, 20])
        @it.send(:by_list)[:by_second].should == [10, 20]
      end
    end

    
    describe "by_minute parameter" do

      it "should accept a single integer" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_minute => 10)
        @it.send(:by_list)[:by_minute].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_minute => [10, 20])
        @it.send(:by_list)[:by_minute].should == [10, 20]
      end
    end

    describe "freq accessors" do
      before(:each) do
        @it = RiCal::RecurrenceRule.new(:freq => 'daily')
      end

      it "should convert the initial value to uppercase" do
        @it.freq.should == 'DAILY'
      end

      it "should convert the setter value to uppercase " do
        @it.freq = 'weekly'
        @it.freq.should == 'WEEKLY'
      end

      it "should not accept an invalid value" do
        @it.freq = 'bogus'
        @it.should_not be_valid
      end
    end
  end

  describe "initialized from string" do
  end
end
