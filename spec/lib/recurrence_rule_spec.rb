require File.join(File.dirname(__FILE__), %w[.. spec_helper])

require 'lib/recurrence_rule'

AnyMonday = RiCal::RecurrenceRule::RecurringDay.new("MO")
AnyWednesday = RiCal::RecurrenceRule::RecurringDay.new("WE")
FirstOfMonth = RiCal::RecurrenceRule::RecurringMonthDay.new(1)
TenthOfMonth = RiCal::RecurrenceRule::RecurringMonthDay.new(10)
FirstOfYear = RiCal::RecurrenceRule::RecurringYearDay.new(1)
TenthOfYear = RiCal::RecurrenceRule::RecurringYearDay.new(10)
SecondWeekOfYear = RiCal::RecurrenceRule::RecurringNumberedWeek.new(2)
LastWeekOfYear = RiCal::RecurrenceRule::RecurringNumberedWeek.new(-1)

# rfc 2445 4.3.10 p.40
describe RiCal::RecurrenceRule do

  describe "initialized from hash" do
    it "should require a frequency" do
      @it = RiCal::RecurrenceRule.new({})
      @it.should_not be_valid
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

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_second => [-1, 0, 59, 60])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for by_second', '60 is invalid for by_second']
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

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_minute => [-1, 0, 59, 60])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for by_minute', '60 is invalid for by_minute']
      end
    end

    describe "by_hour parameter" do

      it "should accept a single integer" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_hour => 10)
        @it.send(:by_list)[:by_hour].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_hour => [10, 12])
        @it.send(:by_list)[:by_hour].should == [10, 12]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_hour => [-1, 0, 23, 24])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for by_hour', '24 is invalid for by_hour']
      end
    end

    describe "by_day parameter" do

      it "should accept a single value" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_day => 'MO')
        @it.send(:by_list)[:by_day].should == [AnyMonday]
      end

      it "should accept an array of values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_day => ['MO', 'WE'])
        @it.send(:by_list)[:by_day].should == [AnyMonday, AnyWednesday]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_day => ['VE'])
        @it.should_not be_valid
        @it.errors.should == ['"VE" is not a valid day']
      end
    end

    describe "by_month_day parameter" do

      it "should accept a single value" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_month_day => 1)
        @it.send(:by_list)[:by_month_day].should == [FirstOfMonth]
      end

      it "should accept an array of values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_month_day => [1, 10])
        @it.send(:by_list)[:by_month_day].should == [FirstOfMonth, TenthOfMonth]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_month_day => [0, 32, 'VE'])
        @it.should_not be_valid
        @it.errors.should == ['0 is not a valid month day','32 is not a valid month day', '"VE" is not a valid month day']
      end
    end

    describe "by_year_day parameter" do

      it "should accept a single value" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_year_day => 1)
        @it.send(:by_list)[:by_year_day].should == [FirstOfYear]
      end

      it "should accept an array of values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_year_day => [1, 10])
        @it.send(:by_list)[:by_year_day].should == [FirstOfYear, TenthOfYear]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_year_day => [0, 370, 'VE'])
        @it.should_not be_valid
        @it.errors.should == ['0 is not a valid year day', '370 is not a valid year day', '"VE" is not a valid year day']
      end
    end

    describe "by_week_no parameter" do

      it "should accept a single value" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_week_no => 2)
        @it.send(:by_list)[:by_week_no].should == [SecondWeekOfYear]
      end

      it "should accept an array of values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_week_no => [2, -1])
        @it.send(:by_list)[:by_week_no].should == [SecondWeekOfYear, LastWeekOfYear]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_week_no => [0, 54, 'VE'])
        @it.should_not be_valid
        @it.errors.should == ['0 is not a valid week number', '54 is not a valid week number', '"VE" is not a valid week number']
      end
    end

    describe "by_month parameter" do

      it "should accept a single integer" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_month => 10)
        @it.send(:by_list)[:by_month].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_month => [10, 12])
        @it.send(:by_list)[:by_month].should == [10, 12]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_month => [-1, 0, 1, 12, 13])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for by_month', '0 is invalid for by_month', '13 is invalid for by_month']
      end
    end

    describe "by_setpos parameter" do

      it "should accept a single integer" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_month => 10, :by_setpos => 2)
        @it.send(:by_list)[:by_setpos].should == [2]
      end

      it "should accept an array of integers" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_month => 10, :by_setpos => [2, 3])
        @it.send(:by_list)[:by_setpos].should == [2, 3]
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_month => 10, :by_setpos => [-367, -366, -1, 0, 1, 366, 367])
        @it.should_not be_valid
        @it.errors.should == ['-367 is invalid for by_setpos', '0 is invalid for by_setpos', '367 is invalid for by_setpos']
      end

      it "should require another BYxxx rule part" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :by_setpos => 2)
        @it.should_not be_valid
        @it.errors.should == ['by_setpos cannot be used without another by_xxx rule part']
      end
    end

    describe "wkst parameter" do

      it "should default to MO" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily")
        @it.wkst.should == 'MO'
      end

      it "should accept a single string" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :wkst => 'SU')
        @it.wkst.should == 'SU'
      end

      %w{MO TU WE TH FR SA SU}.each do |valid|
        it "should accept #{valid} as a valid value" do
          RiCal::RecurrenceRule.new(:freq => "daily", :wkst => valid).should be_valid
        end
      end

      it "should reject invalid values" do
        @it = RiCal::RecurrenceRule.new(:freq => "daily", :wkst => "bogus")
        @it.should_not be_valid
        @it.errors.should == ['"bogus" is invalid for wkst']
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

  describe "to_ical" do

    it "should handle basic cases" do
      RiCal::RecurrenceRule.new(:freq => "daily").to_ical.should == "FREQ=DAILY"
    end

    it "should handle multiple parts" do
      @it = RiCal::RecurrenceRule.new(:freq => "daily", :count => 10, :interval => 2).to_ical
      @it.should match /^FREQ=DAILY;/
      parts = @it.split(';')
      parts.should include("COUNT=10")
      parts.should include("INTERVAL=2")
    end

    it "should supress the default interval value" do
      RiCal::RecurrenceRule.new(:freq => "daily", :interval => 1).to_ical.should_not match(/INTERVAL=/)
    end

    it "should support the wkst value" do
      RiCal::RecurrenceRule.new(:freq => "daily", :wkst => 'SU').to_ical.split(";").should include("WKST=SU")
    end

    it "should supress the default wkst value" do
      RiCal::RecurrenceRule.new(:freq => "daily", :wkst => 'MO').to_ical.split(";").should_not include("WKST=SU")
    end

    it "should handle a scalar by_second" do
      RiCal::RecurrenceRule.new(:freq => "daily", :by_second => 15).to_ical.split(";").should include("BYSECOND=15")
    end

    it "should handle an array by_second" do
      RiCal::RecurrenceRule.new(:freq => "daily", :by_second => [15, 45]).to_ical.split(";").should include("BYSECOND=15,45")
    end

    it "should handle a scalar by_day" do
      RiCal::RecurrenceRule.new(:freq => "monthly", :by_day => 'MO').to_ical.split(";").should include("BYDAY=MO")
    end

    it "should handle an array by_day" do
      RiCal::RecurrenceRule.new(:freq => "daily", :by_day => ["MO", "-3SU"]).to_ical.split(";").should include("BYDAY=MO,-3SU")
    end

    it "should handle a scalar by_month_day" do
      RiCal::RecurrenceRule.new(:freq => "monthly", :by_month_day => 14).to_ical.split(";").should include("BYMONTHDAY=14")
    end

    it "should handle an array by_month_day" do
      RiCal::RecurrenceRule.new(:freq => "daily", :by_month_day => [15, -10]).to_ical.split(";").should include("BYMONTHDAY=15,-10")
    end

    it "should handle a scalar by_year_day" do
      RiCal::RecurrenceRule.new(:freq => "monthly", :by_year_day => 14).to_ical.split(";").should include("BYYEARDAY=14")
    end

    it "should handle an array by_year_day" do
      RiCal::RecurrenceRule.new(:freq => "daily", :by_year_day => [15, -10]).to_ical.split(";").should include("BYYEARDAY=15,-10")
    end

    it "should handle a scalar by_weekno" do
      RiCal::RecurrenceRule.new(:freq => "monthly", :by_week_no => 14).to_ical.split(";").should include("BYWEEKNO=14")
    end

    it "should handle an array by_year_day" do
      RiCal::RecurrenceRule.new(:freq => "daily", :by_week_no => [15, -10]).to_ical.split(";").should include("BYWEEKNO=15,-10")
    end

    it "should handle a scalar by_month" do
      RiCal::RecurrenceRule.new(:freq => "monthly", :by_month => 2).to_ical.split(";").should include("BYMONTH=2")
    end

    it "should handle an array by_month" do
      RiCal::RecurrenceRule.new(:freq => "daily", :by_month => [5, 6]).to_ical.split(";").should include("BYMONTH=5,6")
    end

    it "should handle a scalar by_setpos" do
      RiCal::RecurrenceRule.new(:freq => "monthly", :by_day => %w{MO TU WE TH FR}, :by_setpos => -1).to_ical.split(";").should include("BYSETPOS=-1")
    end

    it "should handle an array by_setpos" do
      RiCal::RecurrenceRule.new(:freq => "monthly", :by_day => %w{MO TU WE TH FR}, :by_setpos => [2, -1]).to_ical.split(";").should include("BYSETPOS=2,-1")
    end
  end
end

describe RiCal::RecurrenceRule::RecurringDay do
  describe "MO - any monday" do
    before(:each) do
      @it= RiCal::RecurrenceRule::RecurringDay.new("MO")
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
      @it= RiCal::RecurrenceRule::RecurringDay.new("TU")
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
      @it= RiCal::RecurrenceRule::RecurringDay.new("WE")
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
      @it= RiCal::RecurrenceRule::RecurringDay.new("TH")
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
      @it= RiCal::RecurrenceRule::RecurringDay.new("FR")
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
      @it= RiCal::RecurrenceRule::RecurringDay.new("SA")
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
      @it= RiCal::RecurrenceRule::RecurringDay.new("SU")
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
      @it = RiCal::RecurrenceRule::RecurringDay.new("1MO")
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
      @it = RiCal::RecurrenceRule::RecurringDay.new("5MO")
    end

    it "should match the fifth Monday of a month with five Mondays" do
      @it.should include(Date.parse("Dec 29 2008"))
    end
  end

  describe "-1MO - last Monday" do
    before(:each) do
      @it = RiCal::RecurrenceRule::RecurringDay.new("-1MO")
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

  describe "leap year sensitivities" do
    before(:each) do
      @it = RiCal::RecurrenceRule::RecurringDay.new("MO")
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
end

describe RiCal::RecurrenceRule::RecurringMonthDay do
  it "should have its computation behavior specified"
end

describe RiCal::RecurrenceRule::RecurringYearDay do
  it "should have its computation behavior specified"
end

describe RiCal::RecurrenceRule::RecurringNumberedWeek do
  it "should have its computation behavior specified"
end
