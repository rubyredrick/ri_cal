require File.join(File.dirname(__FILE__), %w[.. spec_helper])

require 'lib/recurrence_rule_value'

AnyMonday = RiCal::RecurrenceRuleValue::RecurringDay.new("MO")
AnyWednesday = RiCal::RecurrenceRuleValue::RecurringDay.new("WE")
FirstOfMonth = RiCal::RecurrenceRuleValue::RecurringMonthDay.new(1)
TenthOfMonth = RiCal::RecurrenceRuleValue::RecurringMonthDay.new(10)
FirstOfYear = RiCal::RecurrenceRuleValue::RecurringYearDay.new(1)
TenthOfYear = RiCal::RecurrenceRuleValue::RecurringYearDay.new(10)
SecondWeekOfYear = RiCal::RecurrenceRuleValue::RecurringNumberedWeek.new(2)
LastWeekOfYear = RiCal::RecurrenceRuleValue::RecurringNumberedWeek.new(-1)

# rfc 2445 4.3.10 p.40
describe RiCal::RecurrenceRuleValue do

  describe "initialized from hash" do
    it "should require a frequency" do
      @it = RiCal::RecurrenceRuleValue.new({})
      @it.should_not be_valid
      @it.errors.should include("RecurrenceRule must have a value for FREQ")
    end

    it "accept reject an invalid frequency" do
      @it = RiCal::RecurrenceRuleValue.new(:freq => "blort")
      @it.should_not be_valid
      @it.errors.should include("Invalid frequency 'blort'")
    end

    %w{secondly SECONDLY minutely MINUTELY hourly HOURLY daily DAILY weekly WEEKLY monthly MONTHLY
      yearly YEARLY
      }.each do | freq_val |
        it "should accept a frequency of #{freq_val}" do
          RiCal::RecurrenceRuleValue.new(:freq => freq_val).should be_valid
        end
      end

    it "should reject setting both until and count" do
      @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :until => Time.now, :count => 10)
      @it.should_not be_valid
      @it.errors.should include("COUNT and UNTIL cannot both be specified")
    end

    describe "interval parameter" do

      # p 42
      it "should default to 1" do
        RiCal::RecurrenceRuleValue.new(:freq => "daily").interval.should == 1
      end

      it "should accept an explicit value" do
        RiCal::RecurrenceRuleValue.new(:freq => "daily", :interval => 42).interval.should == 42
      end

      it "should reject a negative value" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :interval => -1)
        @it.should_not be_valid
      end
    end

    describe "bysecond parameter" do

      it "should accept a single integer" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bysecond => 10)
        @it.send(:by_list)[:bysecond].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bysecond => [10, 20])
        @it.send(:by_list)[:bysecond].should == [10, 20]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bysecond => [-1, 0, 59, 60])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for bysecond', '60 is invalid for bysecond']
      end
    end

    describe "byminute parameter" do

      it "should accept a single integer" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byminute => 10)
        @it.send(:by_list)[:byminute].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byminute => [10, 20])
        @it.send(:by_list)[:byminute].should == [10, 20]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byminute => [-1, 0, 59, 60])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for byminute', '60 is invalid for byminute']
      end
    end

    describe "byhour parameter" do

      it "should accept a single integer" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byhour => 10)
        @it.send(:by_list)[:byhour].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byhour => [10, 12])
        @it.send(:by_list)[:byhour].should == [10, 12]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byhour => [-1, 0, 23, 24])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for byhour', '24 is invalid for byhour']
      end
    end

    describe "byday parameter" do

      it "should accept a single value" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byday => 'MO')
        @it.send(:by_list)[:byday].should == [AnyMonday]
      end

      it "should accept an array of values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byday => ['MO', 'WE'])
        @it.send(:by_list)[:byday].should == [AnyMonday, AnyWednesday]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byday => ['VE'])
        @it.should_not be_valid
        @it.errors.should == ['"VE" is not a valid day']
      end
    end

    describe "bymonthday parameter" do

      it "should accept a single value" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bymonthday => 1)
        @it.send(:by_list)[:bymonthday].should == [FirstOfMonth]
      end

      it "should accept an array of values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bymonthday => [1, 10])
        @it.send(:by_list)[:bymonthday].should == [FirstOfMonth, TenthOfMonth]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bymonthday => [0, 32, 'VE'])
        @it.should_not be_valid
        @it.errors.should == ['0 is not a valid month day','32 is not a valid month day', '"VE" is not a valid month day']
      end
    end

    describe "byyearday parameter" do

      it "should accept a single value" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byyearday => 1)
        @it.send(:by_list)[:byyearday].should == [FirstOfYear]
      end

      it "should accept an array of values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byyearday => [1, 10])
        @it.send(:by_list)[:byyearday].should == [FirstOfYear, TenthOfYear]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byyearday => [0, 370, 'VE'])
        @it.should_not be_valid
        @it.errors.should == ['0 is not a valid year day', '370 is not a valid year day', '"VE" is not a valid year day']
      end
    end

    describe "byweekno parameter" do

      it "should accept a single value" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byweekno => 2)
        @it.send(:by_list)[:byweekno].should == [SecondWeekOfYear]
      end

      it "should accept an array of values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byweekno => [2, -1])
        @it.send(:by_list)[:byweekno].should == [SecondWeekOfYear, LastWeekOfYear]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :byweekno => [0, 54, 'VE'])
        @it.should_not be_valid
        @it.errors.should == ['0 is not a valid week number', '54 is not a valid week number', '"VE" is not a valid week number']
      end
    end

    describe "bymonth parameter" do

      it "should accept a single integer" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bymonth => 10)
        @it.send(:by_list)[:bymonth].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bymonth => [10, 12])
        @it.send(:by_list)[:bymonth].should == [10, 12]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bymonth => [-1, 0, 1, 12, 13])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for bymonth', '0 is invalid for bymonth', '13 is invalid for bymonth']
      end
    end

    describe "bysetpos parameter" do

      it "should accept a single integer" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bymonth => 10, :bysetpos => 2)
        @it.send(:by_list)[:bysetpos].should == [2]
      end

      it "should accept an array of integers" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bymonth => 10, :bysetpos => [2, 3])
        @it.send(:by_list)[:bysetpos].should == [2, 3]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bymonth => 10, :bysetpos => [-367, -366, -1, 0, 1, 366, 367])
        @it.should_not be_valid
        @it.errors.should == ['-367 is invalid for bysetpos', '0 is invalid for bysetpos', '367 is invalid for bysetpos']
      end

      it "should require another BYxxx rule part" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :bysetpos => 2)
        @it.should_not be_valid
        @it.errors.should == ['bysetpos cannot be used without another by_xxx rule part']
      end
    end

    describe "wkst parameter" do

      it "should default to MO" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily")
        @it.wkst.should == 'MO'
      end

      it "should accept a single string" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :wkst => 'SU')
        @it.wkst.should == 'SU'
      end

      %w{MO TU WE TH FR SA SU}.each do |valid|
        it "should accept #{valid} as a valid value" do
          RiCal::RecurrenceRuleValue.new(:freq => "daily", :wkst => valid).should be_valid
        end
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :wkst => "bogus")
        @it.should_not be_valid
        @it.errors.should == ['"bogus" is invalid for wkst']
      end
    end

    describe "freq accessors" do
      before(:each) do
        @it = RiCal::RecurrenceRuleValue.new(:freq => 'daily')
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

  describe "initialized from parser" do

    describe "from 'FREQ=YEARLY;INTERVAL=2;BYMONTH=1;BYDAY=SU;BYHOUR=8,9;BYMINUTE=30'" do

      before(:all) do
        lambda {
          @it = RiCal::RecurrenceRuleValue.new(:value => 'FREQ=YEARLY;INTERVAL=2;BYMONTH=1;BYDAY=SU;BYHOUR=8,9;BYMINUTE=30')
          }.should_not raise_error
      end
      
      it "should have a frequency of yearly" do
        @it.freq.should == "YEARLY"
      end
      
      it "should have an interval of 2" do
        @it.interval.should == 2
      end
    end
  end

  describe "to_ical" do

    it "should handle basic cases" do
      RiCal::RecurrenceRuleValue.new(:freq => "daily").to_ical.should == "FREQ=DAILY"
    end

    it "should handle multiple parts" do
      @it = RiCal::RecurrenceRuleValue.new(:freq => "daily", :count => 10, :interval => 2).to_ical
      @it.should match /^FREQ=DAILY;/
      parts = @it.split(';')
      parts.should include("COUNT=10")
      parts.should include("INTERVAL=2")
    end

    it "should supress the default interval value" do
      RiCal::RecurrenceRuleValue.new(:freq => "daily", :interval => 1).to_ical.should_not match(/INTERVAL=/)
    end

    it "should support the wkst value" do
      RiCal::RecurrenceRuleValue.new(:freq => "daily", :wkst => 'SU').to_ical.split(";").should include("WKST=SU")
    end

    it "should supress the default wkst value" do
      RiCal::RecurrenceRuleValue.new(:freq => "daily", :wkst => 'MO').to_ical.split(";").should_not include("WKST=SU")
    end

    it "should handle a scalar bysecond" do
      RiCal::RecurrenceRuleValue.new(:freq => "daily", :bysecond => 15).to_ical.split(";").should include("BYSECOND=15")
    end

    it "should handle an array bysecond" do
      RiCal::RecurrenceRuleValue.new(:freq => "daily", :bysecond => [15, 45]).to_ical.split(";").should include("BYSECOND=15,45")
    end

    it "should handle a scalar byday" do
      RiCal::RecurrenceRuleValue.new(:freq => "monthly", :byday => 'MO').to_ical.split(";").should include("BYDAY=MO")
    end

    it "should handle an array byday" do
      RiCal::RecurrenceRuleValue.new(:freq => "daily", :byday => ["MO", "-3SU"]).to_ical.split(";").should include("BYDAY=MO,-3SU")
    end

    it "should handle a scalar bymonthday" do
      RiCal::RecurrenceRuleValue.new(:freq => "monthly", :bymonthday => 14).to_ical.split(";").should include("BYMONTHDAY=14")
    end

    it "should handle an array bymonthday" do
      RiCal::RecurrenceRuleValue.new(:freq => "daily", :bymonthday => [15, -10]).to_ical.split(";").should include("BYMONTHDAY=15,-10")
    end

    it "should handle a scalar byyearday" do
      RiCal::RecurrenceRuleValue.new(:freq => "monthly", :byyearday => 14).to_ical.split(";").should include("BYYEARDAY=14")
    end

    it "should handle an array byyearday" do
      RiCal::RecurrenceRuleValue.new(:freq => "daily", :byyearday => [15, -10]).to_ical.split(";").should include("BYYEARDAY=15,-10")
    end

    it "should handle a scalar byweekno" do
      RiCal::RecurrenceRuleValue.new(:freq => "monthly", :byweekno => 14).to_ical.split(";").should include("BYWEEKNO=14")
    end

    it "should handle an array byyearday" do
      RiCal::RecurrenceRuleValue.new(:freq => "daily", :byweekno => [15, -10]).to_ical.split(";").should include("BYWEEKNO=15,-10")
    end

    it "should handle a scalar bymonth" do
      RiCal::RecurrenceRuleValue.new(:freq => "monthly", :bymonth => 2).to_ical.split(";").should include("BYMONTH=2")
    end

    it "should handle an array bymonth" do
      RiCal::RecurrenceRuleValue.new(:freq => "daily", :bymonth => [5, 6]).to_ical.split(";").should include("BYMONTH=5,6")
    end

    it "should handle a scalar bysetpos" do
      RiCal::RecurrenceRuleValue.new(:freq => "monthly", :byday => %w{MO TU WE TH FR}, :bysetpos => -1).to_ical.split(";").should include("BYSETPOS=-1")
    end

    it "should handle an array bysetpos" do
      RiCal::RecurrenceRuleValue.new(:freq => "monthly", :byday => %w{MO TU WE TH FR}, :bysetpos => [2, -1]).to_ical.split(";").should include("BYSETPOS=2,-1")
    end
  end
end

describe RiCal::RecurrenceRuleValue::WeekNumCalculator do
  before(:each) do
    @it = Object.new
    @it.extend RiCal::RecurrenceRuleValue::WeekNumCalculator
  end

  describe "#week_one" do
    describe "with a monday week start" do
      it "should return Jan 3, 2000 for 2000" do
        @it.week_one(2000, 1).should == Date.new(2000, 1, 3)
      end
  
      it "should return Jan 1, 2001 for 2001" do
        @it.week_one(2001, 1).should == Date.new(2001, 1,1)
      end
  
      it "should return Dec 31, 2001 for 2002" do
        @it.week_one(2002, 1).should == Date.new(2001, 12, 31)
      end
  
      it "should return Dec 30, 2002 for 2003" do
        @it.week_one(2003, 1).should == Date.new(2002, 12, 30)
      end
  
      it "should return Dec 29, 2003 for 2004" do
        @it.week_one(2004, 1).should == Date.new(2003, 12, 29)
      end
    end
    
    it "should return Jan 2, 2001 for 2001 with a Tuesday week start" do
      @it.week_one(2001, 2).should == Date.new(2001, 1, 2)
    end
    
    it "should return Jan 3, 2001 for 2001 with a Wednesday week start" do
      @it.week_one(2001, 3).should == Date.new(2001, 1, 3)
    end
    
    it "should return Jan 4, 2001 for 2001 with a Thursday week start" do
      @it.week_one(2001, 4).should == Date.new(2001, 1, 4)
    end
    
    it "should return Dec 29, 2000 for 2001 with a Friday week start" do
      @it.week_one(2001, 5).should == Date.new(2000, 12, 29)
    end
    
    it "should return Dec 30, 2000 for 2001 with a Saturday week start" do
      @it.week_one(2001, 6).should == Date.new(2000, 12, 30)
    end
    
    it "should return Dec 31, 2000 for 2001 with a Sunday week start" do
      @it.week_one(2001, 0).should == Date.new(2000, 12, 31)
    end
  end

  describe "#week_num" do

    it "should calculate week 1 for January 1, 2001 for a wkst of 1 (Monday)" do
      @it.week_num(Date.new(2001, 1,1), 1).should == 1
    end
    
    it "should calculate week 1 for January 7, 2001 for a wkst of 1 (Monday)" do
      @it.week_num(Date.new(2001, 1,7), 1).should == 1
    end
    
    it "should calculate week 2 for January 8, 2001 for a wkst of 1 (Monday)" do
      @it.week_num(Date.new(2001, 1,8), 1).should == 2
    end
    
    it "should calculate week 52 for December 31, 2000 for a wkst of 1 (Monday)" do
      @it.week_num(Date.new(2000, 12,31), 1).should == 52
    end

    it "should calculate week 52 for January 1, 2001 for a wkst of 2 (Tuesday)" do
      @it.week_num(Date.new(2001, 1, 1), 2).should == 52
    end

    it "should calculate week 1 for Dec 31, 2003 for a wkst of 1 (Monday)" do
      @it.week_num(Date.new(2003, 12, 31), 1, true).should == 1
    end
  end

end

describe RiCal::RecurrenceRuleValue::MonthLengthCalculator do
  before(:each) do
    @it = Object.new
    @it.extend RiCal::RecurrenceRuleValue::MonthLengthCalculator
  end

  describe "#leap_year" do
    it "should return true for 2000" do
      @it.leap_year(2000).should be_true
    end

    it "should return false for 2007" do
      @it.leap_year(2007).should_not be_true
    end

    it "should return true for 2008" do
      @it.leap_year(2008).should be_true
    end

    it "should return false for 2100" do
      @it.leap_year(2100).should_not be_true
    end
  end

  describe "#days_in_month" do

    it "should return 29 for February in a leap year" do
      @it.days_in_month(Date.new(2008, 2, 1)).should == 29
    end

    it "should return 28 for February in a non-leap year" do
      @it.days_in_month(Date.new(2009, 2, 1)).should == 28
    end

    it "should return 31 for January in a leap year" do
      @it.days_in_month(Date.new(2008, 1, 1)).should == 31
    end

    it "should return 31 for January in a non-leap year" do
      @it.days_in_month(Date.new(2009, 1, 1)).should == 31
    end
  end
end


describe RiCal::RecurrenceRuleValue::RecurringDay do
  describe "MO - any monday" do
    before(:each) do
      @it= RiCal::RecurrenceRuleValue::RecurringDay.new("MO")
    end

    it "should include all Mondays" do
      [1, 8, 15, 22, 29].each do | day |
        @it.should include(Date.parse("Dec #{day} 2008"))
      end
    end

    it "should not include non-Mondays" do
      (9..14).each do | day |
        @it.should_not include(Date.parse("Dec #{day} 2008"))
      end
    end
  end

  describe "TU - any Tuesday" do
    before(:each) do
      @it= RiCal::RecurrenceRuleValue::RecurringDay.new("TU")
    end

    it "should include all Tuesdays" do
      [2, 9, 16, 23, 30].each do | day |
        @it.should include(Date.parse("Dec #{day} 2008"))
      end
    end

    it "should not include non-Tuesdays" do
      (10..15).each do | day |
        @it.should_not include(Date.parse("Dec #{day} 2008"))
      end
    end
  end

  describe "WE - any Wednesday" do
    before(:each) do
      @it= RiCal::RecurrenceRuleValue::RecurringDay.new("WE")
    end

    it "should include all Wednesdays" do
      [3, 10, 17, 24, 31].each do | day |
        @it.should include(Date.parse("Dec #{day} 2008"))
      end
    end

    it "should not include non-Wednesdays" do
      (11..16).each do | day |
        @it.should_not include(Date.parse("Dec #{day} 2008"))
      end
    end
  end

  describe "TH - any Thursday" do
    before(:each) do
      @it= RiCal::RecurrenceRuleValue::RecurringDay.new("TH")
    end

    it "should include all Thursdays" do
      [4, 11, 18, 25].each do | day |
        @it.should include(Date.parse("Dec #{day} 2008"))
      end
    end

    it "should not include non-Thursdays" do
      (5..10).each do | day |
        @it.should_not include(Date.parse("Dec #{day} 2008"))
      end
    end
  end

  describe "FR - any Friday" do
    before(:each) do
      @it= RiCal::RecurrenceRuleValue::RecurringDay.new("FR")
    end

    it "should include all Fridays" do
      [5, 12, 19, 26].each do | day |
        @it.should include(Date.parse("Dec #{day} 2008"))
      end
    end

    it "should not include non-Fridays" do
      (6..11).each do | day |
        @it.should_not include(Date.parse("Dec #{day} 2008"))
      end
    end
  end

  describe "SA - any Saturday" do
    before(:each) do
      @it= RiCal::RecurrenceRuleValue::RecurringDay.new("SA")
    end

    it "should include all Saturdays" do
      [6, 13, 20, 27].each do | day |
        @it.should include(Date.parse("Dec #{day} 2008"))
      end
    end

    it "should not include non-Saturdays" do
      (7..12).each do | day |
        @it.should_not include(Date.parse("Dec #{day} 2008"))
      end
    end
  end

  describe "SU - any Sunday" do
    before(:each) do
      @it= RiCal::RecurrenceRuleValue::RecurringDay.new("SU")
    end

    it "should include all Sundays" do
      [7, 14, 21, 28].each do | day |
        @it.should include(Date.parse("Dec #{day} 2008"))
      end
    end

    it "should not include non-Saturdays" do
      (8..13).each do | day |
        @it.should_not include(Date.parse("Dec #{day} 2008"))
      end
    end
  end

  describe "1MO - first Monday" do
    before(:each) do
      @it = RiCal::RecurrenceRuleValue::RecurringDay.new("1MO")
    end

    it "should match the first Monday of the month" do
      @it.should include(Date.parse("Nov 3 2008"))
    end

    it "should not include other Mondays" do
      [10, 17, 24].each do |day|
        @it.should_not include Date.parse("Nov #{day} 2008")
      end
    end
  end

  describe "5MO - Fifth Monday" do
    before(:each) do
      @it = RiCal::RecurrenceRuleValue::RecurringDay.new("5MO")
    end

    it "should match the fifth Monday of a month with five Mondays" do
      @it.should include(Date.parse("Dec 29 2008"))
    end
  end

  describe "-1MO - last Monday" do
    before(:each) do
      @it = RiCal::RecurrenceRuleValue::RecurringDay.new("-1MO")
    end

    it "should match the last Monday of the month" do
      @it.should include(Date.parse("Dec 29 2008"))
    end

    it "should not include other Mondays" do
      [1, 8, 15, 22].each do |day|
        @it.should_not include Date.parse("Dec #{day} 2008")
      end
    end

    it "should match February 28 for a non leap year when appropriate" do
      @it.should include Date.parse("Feb 28 2005")
    end

    it "should match February 29 for a non leap year when appropriate" do
      @it.should include Date.parse("Feb 29 1988")
    end
  end
end

describe RiCal::RecurrenceRuleValue::RecurringMonthDay do

  describe "with a value of 1" do
    before(:each) do
      @it = RiCal::RecurrenceRuleValue::RecurringMonthDay.new(1)
    end

    it "should match the first of each month" do
      (1..12).each do |month|
        @it.should include(Date.new(2008, month, 1))
      end
    end

    it "should not match other days of the month" do
        (2..31).each do |day|
          @it.should_not include(Date.new(2008, 1, day))
        end
      end

      describe "with a value of -1" do
        before(:each) do
          @it = RiCal::RecurrenceRuleValue::RecurringMonthDay.new(-1)
        end

        it "should match the last of each month" do
          {
            1 => 31, 2 => 29, 3 => 31, 4 => 30, 5 => 31, 6 => 30, 7 => 31,
            8 => 31, 9 => 30, 10 => 31, 11 => 30, 12 => 31
            }.each do |month, last|
              @it.should include(Date.new(2008, month, last))
          end
          @it.should include(Date.new(2007, 2, 28))
        end

        it "should not match other days of the month" do
            (1..30).each do |day|
              @it.should_not include(Date.new(2008, 1, day))
            end
          end
      end
  end
end

describe RiCal::RecurrenceRuleValue::RecurringYearDay do

  describe "with a value of 20" do
    before(:each) do
      @it = RiCal::RecurrenceRuleValue::RecurringYearDay.new(20)
    end

    it "should include January 20 in a non-leap year" do
      @it.should include Date.new(2007, 1, 20)
    end

    it "should include January 20 in a leap year" do
      @it.should include Date.new(2008, 1, 20)
    end
  end

  describe "with a value of 60" do
    before(:each) do
      @it = RiCal::RecurrenceRuleValue::RecurringYearDay.new(60)
    end

    it "should include March 1 in a non-leap year" do
      @it.should include Date.new(2007, 3, 1)
    end

    it "should include February 29 in a leap year" do
      @it.should include Date.new(2008, 2, 29)
    end
  end

  describe "with a value of -1" do
    before(:each) do
      @it = RiCal::RecurrenceRuleValue::RecurringYearDay.new(-1)
    end

    it "should include December 31 in a non-leap year" do
      @it.should include Date.new(2007,12, 31)
    end

    it "should include December 31 in a leap year" do
      @it.should include Date.new(2008,12, 31)
    end
  end

  describe "with a value of -365" do
    before(:each) do
      @it = RiCal::RecurrenceRuleValue::RecurringYearDay.new(-365)
    end

    it "should include January 1 in a non-leap year" do
      @it.should include Date.new(2007,1, 1)
    end

    it "should include January 2 in a leap year" do
      @it.should include Date.new(2008,1, 2)
    end
  end

  describe "with a value of -366" do
    before(:each) do
      @it = RiCal::RecurrenceRuleValue::RecurringYearDay.new(-366)
    end

    it "should not include January 1 in a non-leap year" do
      @it.should_not include Date.new(2007,1, 1)
    end

    it "should include January 1 in a leap year" do
      @it.should include Date.new(2008,1, 1)
    end
  end
end

describe RiCal::RecurrenceRuleValue::RecurringNumberedWeek do
  before(:each) do
    @it = RiCal::RecurrenceRuleValue::RecurringNumberedWeek.new(50)
  end
  
  it "should not include Dec 10, 2000" do
    @it.should_not include(Date.new(2000, 12, 10))
  end
  
  it "should include Dec 11, 2000" do
    @it.should include(Date.new(2000, 12, 11))
  end
  
  it "should include Dec 17, 2000" do
    @it.should include(Date.new(2000, 12, 17))
  end
  
  it "should not include Dec 18, 2000" do
    @it.should_not include(Date.new(2000, 12, 18))
  end
end
