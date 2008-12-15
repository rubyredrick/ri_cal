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
  
  describe "initialized from string" do
  end
end
