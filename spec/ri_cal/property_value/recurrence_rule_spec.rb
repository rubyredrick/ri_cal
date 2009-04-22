require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

require 'rubygems'

FirstOfMonth = RiCal::PropertyValue::RecurrenceRule::RecurringMonthDay.new(1)
TenthOfMonth = RiCal::PropertyValue::RecurrenceRule::RecurringMonthDay.new(10)
FirstOfYear = RiCal::PropertyValue::RecurrenceRule::RecurringYearDay.new(1)
TenthOfYear = RiCal::PropertyValue::RecurrenceRule::RecurringYearDay.new(10)
SecondWeekOfYear = RiCal::PropertyValue::RecurrenceRule::RecurringNumberedWeek.new(2)
LastWeekOfYear = RiCal::PropertyValue::RecurrenceRule::RecurringNumberedWeek.new(-1)

# rfc 2445 4.3.10 p.40
describe RiCal::PropertyValue::RecurrenceRule do

  describe "initialized from hash" do
    it "should require a frequency" do
      @it = RiCal::PropertyValue::RecurrenceRule.new({})
      @it.should_not be_valid
      @it.errors.should include("RecurrenceRule must have a value for FREQ")
    end

    it "accept reject an invalid frequency" do
      @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "blort")
      @it.should_not be_valid
      @it.errors.should include("Invalid frequency 'blort'")
    end

    %w{secondly SECONDLY minutely MINUTELY hourly HOURLY daily DAILY weekly WEEKLY monthly MONTHLY
      yearly YEARLY
      }.each do | freq_val |
        it "should accept a frequency of #{freq_val}" do
          RiCal::PropertyValue::RecurrenceRule.new(:freq => freq_val).should be_valid
        end
      end

    it "should reject setting both until and count" do
      @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :until => Time.now, :count => 10)
      @it.should_not be_valid
      @it.errors.should include("COUNT and UNTIL cannot both be specified")
    end

    describe "interval parameter" do

      # p 42
      it "should default to 1" do
        RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily").interval.should == 1
      end

      it "should accept an explicit value" do
        RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :interval => 42).interval.should == 42
      end

      it "should reject a negative value" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :interval => -1)
        @it.should_not be_valid
      end
    end

    describe "bysecond parameter" do

      it "should accept a single integer" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bysecond => 10)
        @it.send(:by_list)[:bysecond].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bysecond => [10, 20])
        @it.send(:by_list)[:bysecond].should == [10, 20]
      end

      it "should reject invalid values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bysecond => [-1, 0, 59, 60])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for bysecond', '60 is invalid for bysecond']
      end
    end

    describe "byminute parameter" do

      it "should accept a single integer" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byminute => 10)
        @it.send(:by_list)[:byminute].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byminute => [10, 20])
        @it.send(:by_list)[:byminute].should == [10, 20]
      end

      it "should reject invalid values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byminute => [-1, 0, 59, 60])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for byminute', '60 is invalid for byminute']
      end
    end

    describe "byhour parameter" do

      it "should accept a single integer" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byhour => 10)
        @it.send(:by_list)[:byhour].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byhour => [10, 12])
        @it.send(:by_list)[:byhour].should == [10, 12]
      end

      it "should reject invalid values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byhour => [-1, 0, 23, 24])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for byhour', '24 is invalid for byhour']
      end
    end

    describe "byday parameter" do
      
      def anyMonday(rule)
        RiCal::PropertyValue::RecurrenceRule::RecurringDay.new("MO", rule)
      end
      
      def anyWednesday(rule)
        RiCal::PropertyValue::RecurrenceRule::RecurringDay.new("WE", rule)
      end
      

      it "should accept a single value" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byday => 'MO')
        @it.send(:by_list)[:byday].should == [anyMonday(@it)]
      end

      it "should accept an array of values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byday => ['MO', 'WE'])
        @it.send(:by_list)[:byday].should == [anyMonday(@it), anyWednesday(@it)]
      end

      it "should reject invalid values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byday => ['VE'])
        @it.should_not be_valid
        @it.errors.should == ['"VE" is not a valid day']
      end
    end

    describe "bymonthday parameter" do

      it "should accept a single value" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bymonthday => 1)
        @it.send(:by_list)[:bymonthday].should == [FirstOfMonth]
      end

      it "should accept an array of values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bymonthday => [1, 10])
        @it.send(:by_list)[:bymonthday].should == [FirstOfMonth, TenthOfMonth]
      end

      it "should reject invalid values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bymonthday => [0, 32, 'VE'])
        @it.should_not be_valid
        @it.errors.should == ['0 is not a valid month day','32 is not a valid month day', '"VE" is not a valid month day']
      end
    end

    describe "byyearday parameter" do

      it "should accept a single value" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byyearday => 1)
        @it.send(:by_list)[:byyearday].should == [FirstOfYear]
      end

      it "should accept an array of values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byyearday => [1, 10])
        @it.send(:by_list)[:byyearday].should == [FirstOfYear, TenthOfYear]
      end

      it "should reject invalid values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byyearday => [0, 370, 'VE'])
        @it.should_not be_valid
        @it.errors.should == ['0 is not a valid year day', '370 is not a valid year day', '"VE" is not a valid year day']
      end
    end

    describe "byweekno parameter" do

      it "should accept a single value" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byweekno => 2)
        @it.send(:by_list)[:byweekno].should == [SecondWeekOfYear]
      end

      it "should accept an array of values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byweekno => [2, -1])
        @it.send(:by_list)[:byweekno].should == [SecondWeekOfYear, LastWeekOfYear]
      end

      it "should reject invalid values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byweekno => [0, 54, 'VE'])
        @it.should_not be_valid
        @it.errors.should == ['0 is not a valid week number', '54 is not a valid week number', '"VE" is not a valid week number']
      end
    end

    describe "bymonth parameter" do

      it "should accept a single integer" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bymonth => 10)
        @it.send(:by_list)[:bymonth].should == [10]
      end

      it "should accept an array of integers" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bymonth => [10, 12])
        @it.send(:by_list)[:bymonth].should == [10, 12]
      end

      it "should reject invalid values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bymonth => [-1, 0, 1, 12, 13])
        @it.should_not be_valid
        @it.errors.should == ['-1 is invalid for bymonth', '0 is invalid for bymonth', '13 is invalid for bymonth']
      end
    end

    describe "bysetpos parameter" do

      it "should accept a single integer" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bymonth => 10, :bysetpos => 2)
        @it.send(:by_list)[:bysetpos].should == [2]
      end

      it "should accept an array of integers" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bymonth => 10, :bysetpos => [2, 3])
        @it.send(:by_list)[:bysetpos].should == [2, 3]
      end

      it "should reject invalid values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bymonth => 10, :bysetpos => [-367, -366, -1, 0, 1, 366, 367])
        @it.should_not be_valid
        @it.errors.should == ['-367 is invalid for bysetpos', '0 is invalid for bysetpos', '367 is invalid for bysetpos']
      end

      it "should require another BYxxx rule part" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bysetpos => 2)
        @it.should_not be_valid
        @it.errors.should == ['bysetpos cannot be used without another by_xxx rule part']
      end
    end

    describe "wkst parameter" do

      it "should default to MO" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily")
        @it.wkst.should == 'MO'
      end

      it "should accept a single string" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :wkst => 'SU')
        @it.wkst.should == 'SU'
      end

      %w{MO TU WE TH FR SA SU}.each do |valid|
        it "should accept #{valid} as a valid value" do
          RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :wkst => valid).should be_valid
        end
      end

      it "should reject invalid values" do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :wkst => "bogus")
        @it.should_not be_valid
        @it.errors.should == ['"bogus" is invalid for wkst']
      end
    end

    describe "freq accessors" do
      before(:each) do
        @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => 'daily')
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
          @it = RiCal::PropertyValue::RecurrenceRule.new(:value => 'FREQ=YEARLY;INTERVAL=2;BYMONTH=1;BYDAY=SU;BYHOUR=8,9;BYMINUTE=30')
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
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily").to_ical.should == "FREQ=DAILY"
    end

    it "should handle multiple parts" do
      @it = RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :count => 10, :interval => 2).to_ical
      @it.should match(/^FREQ=DAILY;/)
      parts = @it.split(';')
      parts.should include("COUNT=10")
      parts.should include("INTERVAL=2")
    end

    it "should supress the default interval value" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :interval => 1).to_ical.should_not match(/INTERVAL=/)
    end

    it "should support the wkst value" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :wkst => 'SU').to_ical.split(";").should include("WKST=SU")
    end

    it "should supress the default wkst value" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :wkst => 'MO').to_ical.split(";").should_not include("WKST=SU")
    end

    it "should handle a scalar bysecond" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bysecond => 15).to_ical.split(";").should include("BYSECOND=15")
    end

    it "should handle an array bysecond" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bysecond => [15, 45]).to_ical.split(";").should include("BYSECOND=15,45")
    end

    it "should handle a scalar byday" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "monthly", :byday => 'MO').to_ical.split(";").should include("BYDAY=MO")
    end

    it "should handle an array byday" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byday => ["MO", "-3SU"]).to_ical.split(";").should include("BYDAY=MO,-3SU")
    end

    it "should handle a scalar bymonthday" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "monthly", :bymonthday => 14).to_ical.split(";").should include("BYMONTHDAY=14")
    end

    it "should handle an array bymonthday" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bymonthday => [15, -10]).to_ical.split(";").should include("BYMONTHDAY=15,-10")
    end

    it "should handle a scalar byyearday" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "monthly", :byyearday => 14).to_ical.split(";").should include("BYYEARDAY=14")
    end

    it "should handle an array byyearday" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byyearday => [15, -10]).to_ical.split(";").should include("BYYEARDAY=15,-10")
    end

    it "should handle a scalar byweekno" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "monthly", :byweekno => 14).to_ical.split(";").should include("BYWEEKNO=14")
    end

    it "should handle an array byyearday" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :byweekno => [15, -10]).to_ical.split(";").should include("BYWEEKNO=15,-10")
    end

    it "should handle a scalar bymonth" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "monthly", :bymonth => 2).to_ical.split(";").should include("BYMONTH=2")
    end

    it "should handle an array bymonth" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "daily", :bymonth => [5, 6]).to_ical.split(";").should include("BYMONTH=5,6")
    end

    it "should handle a scalar bysetpos" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "monthly", :byday => %w{MO TU WE TH FR}, :bysetpos => -1).to_ical.split(";").should include("BYSETPOS=-1")
    end

    it "should handle an array bysetpos" do
      RiCal::PropertyValue::RecurrenceRule.new(:freq => "monthly", :byday => %w{MO TU WE TH FR}, :bysetpos => [2, -1]).to_ical.split(";").should include("BYSETPOS=-1,2")
    end
  end
  
  describe "#enumerator" do

    def self.enumeration_spec(description, dtstart_string, tzid, rrule_string, expectation, debug=false)
      if expectation.last == "..."
        expectation = expectation[0..-2]
        iterations = expectation.length
      else
        iterations = expectation.length + 1
      end

      describe description do
        before(:each) do
          RiCal.debug = debug
          rrule = RiCal::PropertyValue::RecurrenceRule.new(
          :value => rrule_string
          )
          @enum = rrule.enumerator(mock("EventValue", :default_start_time => DateTime.parse(dtstart_string).to_ri_cal_date_time_value, :default_duration => nil))
          @expectations = (expectation.map {|str| str.gsub(/E.T$/,'').to_ri_cal_date_time_value})
        end
        
        after(:each) do
          RiCal.debug = false
        end

        it "should produce the correct occurrences" do
          actuals = []
          (0..(iterations-1)).each do |i|
            occurrence = @enum.next_occurrence
            break if occurrence.nil?
            actuals << occurrence[:start]
            # This is a little strange, we do this to avoid O(n*2)
            unless actuals.last == @expectations[i]
              actuals.should == @expectations[0,actuals.length]
            end
          end
          actuals.length.should == @expectations.length
        end
      end
    end

      enumeration_spec(
      "Daily for 10 occurrences (RFC 2445 p 118)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=DAILY;COUNT=10",
      [
        "9/2/1997 9:00 AM EDT",
        "9/3/1997 9:00 AM EDT",
        "9/4/1997 9:00 AM EDT",
        "9/5/1997 9:00 AM EDT",
        "9/6/1997 9:00 AM EDT",
        "9/7/1997 9:00 AM EDT",
        "9/8/1997 9:00 AM EDT",
        "9/9/1997 9:00 AM EDT",
        "9/10/1997 9:00 AM EDT",
        "9/11/1997 9:00 AM EDT"
      ]
      )

      enumeration_spec(
      "Daily until December 24, 1997 (RFC 2445 p 118)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=DAILY;UNTIL=19971224T000000Z",
      [
        "9/2/1997 9:00 AM EDT",
        "9/3/1997 9:00 AM EDT",
        "9/4/1997 9:00 AM EDT",
        "9/5/1997 9:00 AM EDT",
        "9/6/1997 9:00 AM EDT",
        "9/7/1997 9:00 AM EDT",
        "9/8/1997 9:00 AM EDT",
        "9/9/1997 9:00 AM EDT",
        "9/10/1997 9:00 AM EDT",
        "9/11/1997 9:00 AM EDT",
        "9/12/1997 9:00 AM EDT",
        "9/13/1997 9:00 AM EDT",
        "9/14/1997 9:00 AM EDT",
        "9/15/1997 9:00 AM EDT",
        "9/16/1997 9:00 AM EDT",
        "9/17/1997 9:00 AM EDT",
        "9/18/1997 9:00 AM EDT",
        "9/19/1997 9:00 AM EDT",
        "9/20/1997 9:00 AM EDT",
        "9/21/1997 9:00 AM EDT",
        "9/22/1997 9:00 AM EDT",
        "9/23/1997 9:00 AM EDT",
        "9/24/1997 9:00 AM EDT",
        "9/25/1997 9:00 AM EDT",
        "9/26/1997 9:00 AM EDT",
        "9/27/1997 9:00 AM EDT",
        "9/28/1997 9:00 AM EDT",
        "9/29/1997 9:00 AM EDT",
        "9/30/1997 9:00 AM EDT",
        "10/1/1997 9:00 AM EDT",
        "10/2/1997 9:00 AM EDT",
        "10/3/1997 9:00 AM EDT",
        "10/4/1997 9:00 AM EDT",
        "10/5/1997 9:00 AM EDT",
        "10/6/1997 9:00 AM EDT",
        "10/7/1997 9:00 AM EDT",
        "10/8/1997 9:00 AM EDT",
        "10/9/1997 9:00 AM EDT",
        "10/10/1997 9:00 AM EDT",
        "10/11/1997 9:00 AM EDT",
        "10/12/1997 9:00 AM EDT",
        "10/13/1997 9:00 AM EDT",
        "10/14/1997 9:00 AM EDT",
        "10/15/1997 9:00 AM EDT",
        "10/16/1997 9:00 AM EDT",
        "10/17/1997 9:00 AM EDT",
        "10/18/1997 9:00 AM EDT",
        "10/19/1997 9:00 AM EDT",
        "10/20/1997 9:00 AM EDT",
        "10/21/1997 9:00 AM EDT",
        "10/22/1997 9:00 AM EDT",
        "10/23/1997 9:00 AM EDT",
        "10/24/1997 9:00 AM EDT",
        "10/25/1997 9:00 AM EDT",
        "10/26/1997 9:00 AM EST",
        "10/27/1997 9:00 AM EST",
        "10/28/1997 9:00 AM EST",
        "10/29/1997 9:00 AM EST",
        "10/30/1997 9:00 AM EST",
        "10/31/1997 9:00 AM EST",
        "11/01/1997 9:00 AM EST",
        "11/02/1997 9:00 AM EST",
        "11/03/1997 9:00 AM EST",
        "11/04/1997 9:00 AM EST",
        "11/05/1997 9:00 AM EST",
        "11/06/1997 9:00 AM EST",
        "11/07/1997 9:00 AM EST",
        "11/08/1997 9:00 AM EST",
        "11/09/1997 9:00 AM EST",
        "11/10/1997 9:00 AM EST",
        "11/11/1997 9:00 AM EST",
        "11/12/1997 9:00 AM EST",
        "11/13/1997 9:00 AM EST",
        "11/14/1997 9:00 AM EST",
        "11/15/1997 9:00 AM EST",
        "11/16/1997 9:00 AM EST",
        "11/17/1997 9:00 AM EST",
        "11/18/1997 9:00 AM EST",
        "11/19/1997 9:00 AM EST",
        "11/20/1997 9:00 AM EST",
        "11/21/1997 9:00 AM EST",
        "11/22/1997 9:00 AM EST",
        "11/23/1997 9:00 AM EST",
        "11/24/1997 9:00 AM EST",
        "11/25/1997 9:00 AM EST",
        "11/26/1997 9:00 AM EST",
        "11/27/1997 9:00 AM EST",
        "11/28/1997 9:00 AM EST",
        "11/29/1997 9:00 AM EST",
        "11/30/1997 9:00 AM EST",
        "12/01/1997 9:00 AM EST",
        "12/02/1997 9:00 AM EST",
        "12/03/1997 9:00 AM EST",
        "12/04/1997 9:00 AM EST",
        "12/05/1997 9:00 AM EST",
        "12/06/1997 9:00 AM EST",
        "12/07/1997 9:00 AM EST",
        "12/08/1997 9:00 AM EST",
        "12/09/1997 9:00 AM EST",
        "12/10/1997 9:00 AM EST",
        "12/11/1997 9:00 AM EST",
        "12/12/1997 9:00 AM EST",
        "12/13/1997 9:00 AM EST",
        "12/14/1997 9:00 AM EST",
        "12/15/1997 9:00 AM EST",
        "12/16/1997 9:00 AM EST",
        "12/17/1997 9:00 AM EST",
        "12/18/1997 9:00 AM EST",
        "12/19/1997 9:00 AM EST",
        "12/20/1997 9:00 AM EST",
        "12/21/1997 9:00 AM EST",
        "12/22/1997 9:00 AM EST",
        "12/23/1997 9:00 AM EST",
      ]
      )

      enumeration_spec(
      "Every other day - forever (RFC 2445 p 118)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=DAILY;INTERVAL=2",
      [
        "9/2/1997 9:00 AM EDT",
        "9/4/1997 9:00 AM EDT",
        "9/6/1997 9:00 AM EDT",
        "9/8/1997 9:00 AM EDT",
        "9/10/1997 9:00 AM EDT",
        "9/12/1997 9:00 AM EDT",
        "9/14/1997 9:00 AM EDT",
        "9/16/1997 9:00 AM EDT",
        "9/18/1997 9:00 AM EDT",
        "9/20/1997 9:00 AM EDT",
        "9/22/1997 9:00 AM EDT",
        "9/24/1997 9:00 AM EDT",
        "9/26/1997 9:00 AM EDT",
        "9/28/1997 9:00 AM EDT",
        "9/30/1997 9:00 AM EDT",
        "10/2/1997 9:00 AM EDT",
        "10/4/1997 9:00 AM EDT",
        "10/6/1997 9:00 AM EDT",
        "10/8/1997 9:00 AM EDT",
        "10/10/1997 9:00 AM EDT",
        "10/12/1997 9:00 AM EDT",
        "10/14/1997 9:00 AM EDT",
        "10/16/1997 9:00 AM EDT",
        "10/18/1997 9:00 AM EDT",
        "10/20/1997 9:00 AM EDT",
        "10/22/1997 9:00 AM EDT",
        "10/24/1997 9:00 AM EDT",
        "10/26/1997 9:00 AM EST",
        "10/28/1997 9:00 AM EST",
        "10/30/1997 9:00 AM EST",
        "11/01/1997 9:00 AM EST",
        "11/03/1997 9:00 AM EST",
        "11/05/1997 9:00 AM EST",
        "11/07/1997 9:00 AM EST",
        "11/09/1997 9:00 AM EST",
        "11/11/1997 9:00 AM EST",
        "11/13/1997 9:00 AM EST",
        "11/15/1997 9:00 AM EST",
        "11/17/1997 9:00 AM EST",
        "11/19/1997 9:00 AM EST",
        "11/21/1997 9:00 AM EST",
        "11/23/1997 9:00 AM EST",
        "11/25/1997 9:00 AM EST",
        "11/27/1997 9:00 AM EST",
        "11/29/1997 9:00 AM EST",
        "12/01/1997 9:00 AM EST",
        "12/03/1997 9:00 AM EST",
        "..."
      ]
      )

      enumeration_spec(
      "Every 10 days, 5 occurrences (RFC 2445 p 118-19)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=DAILY;INTERVAL=10;COUNT=5",
      [
        "9/2/1997 9:00 AM EDT",
        "9/12/1997 9:00 AM EDT",
        "9/22/1997 9:00 AM EDT",
        "10/2/1997 9:00 AM EDT",
        "10/12/1997 9:00 AM EDT"
      ]
      )
      
      enumeration_spec(
      "Everyday in January, for 3 years (RFC 2445 p 119)",
      "19980101T090000",
      "US-Eastern",
      "FREQ=DAILY;UNTIL=20000131T090000Z;BYMONTH=1",
      [
        "1/01/1998 9:00 AM EST",
        "1/02/1998 9:00 AM EST",
        "1/03/1998 9:00 AM EST",
        "1/04/1998 9:00 AM EST",
        "1/05/1998 9:00 AM EST",
        "1/06/1998 9:00 AM EST",
        "1/07/1998 9:00 AM EST",
        "1/08/1998 9:00 AM EST",
        "1/09/1998 9:00 AM EST",
        "1/10/1998 9:00 AM EST",
        "1/11/1998 9:00 AM EST",
        "1/12/1998 9:00 AM EST",
        "1/13/1998 9:00 AM EST",
        "1/14/1998 9:00 AM EST",
        "1/15/1998 9:00 AM EST",
        "1/16/1998 9:00 AM EST",
        "1/17/1998 9:00 AM EST",
        "1/18/1998 9:00 AM EST",
        "1/19/1998 9:00 AM EST",
        "1/20/1998 9:00 AM EST",
        "1/21/1998 9:00 AM EST",
        "1/22/1998 9:00 AM EST",
        "1/23/1998 9:00 AM EST",
        "1/24/1998 9:00 AM EST",
        "1/25/1998 9:00 AM EST",
        "1/26/1998 9:00 AM EST",
        "1/27/1998 9:00 AM EST",
        "1/28/1998 9:00 AM EST",
        "1/29/1998 9:00 AM EST",
        "1/30/1998 9:00 AM EST",
        "1/31/1998 9:00 AM EST",
        "1/01/1999 9:00 AM EST",
        "1/02/1999 9:00 AM EST",
        "1/03/1999 9:00 AM EST",
        "1/04/1999 9:00 AM EST",
        "1/05/1999 9:00 AM EST",
        "1/06/1999 9:00 AM EST",
        "1/07/1999 9:00 AM EST",
        "1/08/1999 9:00 AM EST",
        "1/09/1999 9:00 AM EST",
        "1/10/1999 9:00 AM EST",
        "1/11/1999 9:00 AM EST",
        "1/12/1999 9:00 AM EST",
        "1/13/1999 9:00 AM EST",
        "1/14/1999 9:00 AM EST",
        "1/15/1999 9:00 AM EST",
        "1/16/1999 9:00 AM EST",
        "1/17/1999 9:00 AM EST",
        "1/18/1999 9:00 AM EST",
        "1/19/1999 9:00 AM EST",
        "1/20/1999 9:00 AM EST",
        "1/21/1999 9:00 AM EST",
        "1/22/1999 9:00 AM EST",
        "1/23/1999 9:00 AM EST",
        "1/24/1999 9:00 AM EST",
        "1/25/1999 9:00 AM EST",
        "1/26/1999 9:00 AM EST",
        "1/27/1999 9:00 AM EST",
        "1/28/1999 9:00 AM EST",
        "1/29/1999 9:00 AM EST",
        "1/30/1999 9:00 AM EST",
        "1/31/1999 9:00 AM EST",
        "1/01/2000 9:00 AM EST",
        "1/02/2000 9:00 AM EST",
        "1/03/2000 9:00 AM EST",
        "1/04/2000 9:00 AM EST",
        "1/05/2000 9:00 AM EST",
        "1/06/2000 9:00 AM EST",
        "1/07/2000 9:00 AM EST",
        "1/08/2000 9:00 AM EST",
        "1/09/2000 9:00 AM EST",
        "1/10/2000 9:00 AM EST",
        "1/11/2000 9:00 AM EST",
        "1/12/2000 9:00 AM EST",
        "1/13/2000 9:00 AM EST",
        "1/14/2000 9:00 AM EST",
        "1/15/2000 9:00 AM EST",
        "1/16/2000 9:00 AM EST",
        "1/17/2000 9:00 AM EST",
        "1/18/2000 9:00 AM EST",
        "1/19/2000 9:00 AM EST",
        "1/20/2000 9:00 AM EST",
        "1/21/2000 9:00 AM EST",
        "1/22/2000 9:00 AM EST",
        "1/23/2000 9:00 AM EST",
        "1/24/2000 9:00 AM EST",
        "1/25/2000 9:00 AM EST",
        "1/26/2000 9:00 AM EST",
        "1/27/2000 9:00 AM EST",
        "1/28/2000 9:00 AM EST",
        "1/29/2000 9:00 AM EST",
        "1/30/2000 9:00 AM EST",
        "1/31/2000 9:00 AM EST"
      ], true
      )
      
      enumeration_spec(
      "Weekly for 10 occurrences (RFC 2445 p 119)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=WEEKLY;COUNT=10",
      [
        "9/2/1997 9:00 AM EDT",
        "9/9/1997 9:00 AM EDT",
        "9/16/1997 9:00 AM EDT",
        "9/23/1997 9:00 AM EDT",
        "9/30/1997 9:00 AM EDT",
        "10/7/1997 9:00 AM EDT",
        "10/14/1997 9:00 AM EDT",
        "10/21/1997 9:00 AM EDT",
        "10/28/1997 9:00 AM EST",
        "11/4/1997 9:00 AM EST"
      ]
      )
      
      enumeration_spec(
      "Weekly until December 24, 1997 (RFC 2445 p 119)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=WEEKLY;UNTIL=19971224T000000Z",
      [
        "9/2/1997 9:00 AM EDT",
        "9/9/1997 9:00 AM EDT",
        "9/16/1997 9:00 AM EDT",
        "9/23/1997 9:00 AM EDT",
        "9/30/1997 9:00 AM EDT",
        "10/7/1997 9:00 AM EDT",
        "10/14/1997 9:00 AM EDT",
        "10/21/1997 9:00 AM EDT",
        "10/28/1997 9:00 AM EST",
        "11/4/1997 9:00 AM EST",
        "11/11/1997 9:00 AM EST",
        "11/18/1997 9:00 AM EST",
        "11/25/1997 9:00 AM EST",
        "12/2/1997 9:00 AM EST",
        "12/9/1997 9:00 AM EST",
        "12/16/1997 9:00 AM EST",
        "12/23/1997 9:00 AM EST"
      ]
      )
      
      enumeration_spec(
      "Every other week - forever (RFC 2445 p 119)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=WEEKLY;INTERVAL=2;WKST=SU",
      [
        "9/2/1997 9:00 AM EDT",
        "9/16/1997 9:00 AM EDT",
        "9/30/1997 9:00 AM EDT",
        "10/14/1997 9:00 AM EDT",
        "10/28/1997 9:00 AM EST",
        "11/11/1997 9:00 AM EST",
        "11/25/1997 9:00 AM EST",
        "12/9/1997 9:00 AM EST",
        "12/23/1997 9:00 AM EST",
        "1/6/1998 9:00 AM EST",
        "1/20/1998 9:00 AM EST",
        "2/3/1998 9:00 AM EST",
        "..."
      ]
      )
      
      enumeration_spec(
      "Weekly on Tuesday and Thursday for 5 weeks, Alternative 1 (RFC 2445 p 119)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=WEEKLY;UNTIL=19971007T000000Z;WKST=SU;BYDAY=TU,TH",
      [
        "9/2/1997 9:00 AM EDT",
        "9/4/1997 9:00 AM EDT",
        "9/9/1997 9:00 AM EDT",
        "9/11/1997 9:00 AM EDT",
        "9/16/1997 9:00 AM EST",
        "9/18/1997 9:00 AM EST",
        "9/23/1997 9:00 AM EST",
        "9/25/1997 9:00 AM EST",
        "9/30/1997 9:00 AM EST",
        "10/2/1997 9:00 AM EST"
      ]
      )
      
      enumeration_spec(
      "Weekly on Tuesday and Thursday for 5 weeks, Alternative 2 (RFC 2445 p 120)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=WEEKLY;COUNT=10;WKST=SU;BYDAY=TU,TH",
      [
        "9/2/1997 9:00 AM EDT",
        "9/4/1997 9:00 AM EDT",
        "9/9/1997 9:00 AM EDT",
        "9/11/1997 9:00 AM EDT",
        "9/16/1997 9:00 AM EST",
        "9/18/1997 9:00 AM EST",
        "9/23/1997 9:00 AM EST",
        "9/25/1997 9:00 AM EST",
        "9/30/1997 9:00 AM EST",
        "10/2/1997 9:00 AM EST"
      ]
      )
      
      enumeration_spec(
      "Every other week on Monday, Wednesday and Friday until December 24,1997, but starting on Tuesday, September 2, 1997 (RFC 2445 p 120)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=WEEKLY;INTERVAL=2;UNTIL=19971224T000000Z;WKST=SU;BYDAY=MO,WE,FR",
      [
        "9/2/1997 9:00 AM EDT",
        "9/3/1997 9:00 AM EDT",
        "9/5/1997 9:00 AM EDT",
        "9/15/1997 9:00 AM EDT",
        "9/17/1997 9:00 AM EDT",
        "9/19/1997 9:00 AM EDT",
        "9/29/1997 9:00 AM EDT",
        "10/1/1997 9:00 AM EDT",
        "10/3/1997 9:00 AM EDT",
        "10/13/1997 9:00 AM EDT",
        "10/15/1997 9:00 AM EDT",
        "10/17/1997 9:00 AM EDT",
        "10/27/1997 9:00 AM EST",
        "10/29/1997 9:00 AM EST",
        "10/31/1997 9:00 AM EST",
        "11/10/1997 9:00 AM EST",
        "11/12/1997 9:00 AM EST",
        "11/14/1997 9:00 AM EST",
        "11/24/1997 9:00 AM EST",
        "11/26/1997 9:00 AM EST",
        "11/28/1997 9:00 AM EST",
        "12/8/1997 9:00 AM EST",
        "12/10/1997 9:00 AM EST",
        "12/12/1997 9:00 AM EST",
        "12/22/1997 9:00 AM EST"
      ], true
      )
      
      enumeration_spec(
      "Every other week on TU and TH for 8 occurrences (RFC 2445 p 120)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=WEEKLY;INTERVAL=2;COUNT=8;WKST=SU;BYDAY=TU,TH",
      [
        "9/2/1997 9:00 AM EDT",
        "9/4/1997 9:00 AM EDT",
        "9/16/1997 9:00 AM EDT",
        "9/18/1997 9:00 AM EDT",
        "9/30/1997 9:00 AM EDT",
        "10/2/1997 9:00 AM EDT",
        "10/14/1997 9:00 AM EDT",
        "10/16/1997 9:00 AM EDT"
      ], true
      )

      # enumeration_spec(
      # "Monthly on the 1st Friday for ten occurrences (RFC 2445 p 120)",
      # "19970905T090000",
      # "US-Eastern",
      # "FREQ=MONTHLY;COUNT=10;BYDAY=1FR",
      # [
      #   "9/5/1997 9:00 AM EDT",
      #   "10/3/1997 9:00 AM EDT",
      #   "11/7/1997 9:00 AM EST",
      #   "12/5/1997 9:00 AM EST",
      #   "1/2/1998 9:00 AM EST",
      #   "2/6/1998 9:00 AM EST",
      #   "3/6/1998 9:00 AM EST",
      #   "4/3/1998 9:00 AM EST",
      #   "5/1/1998 9:00 AM EDT",
      #   "6/5/1998 9:00 AM EDT",
      # ]#, true
      # )

      enumeration_spec(
      "Monthly on the 1st Friday until December 24, 1997 (RFC 2445 p 120)",
      "19970905T090000",
      "US-Eastern",
      "FREQ=MONTHLY;UNTIL=19971224T000000Z;BYDAY=1FR",
      [
        "9/5/1997 9:00 AM EDT",
        "10/3/1997 9:00 AM EDT",
        "11/7/1997 9:00 AM EST",
        "12/5/1997 9:00 AM EST"
      ]
      )

      enumeration_spec(
      "Every other month on the 1st and last Sunday of the month for 10 occurrences (RFC 2445 p 120)",
      "19970907T090000",
      "US-Eastern",
      "FREQ=MONTHLY;INTERVAL=2;COUNT=10;BYDAY=1SU,-1SU",
      [
        "9/7/1997 9:00 AM EDT",
        "9/28/1997 9:00 AM EDT",
        "11/2/1997 9:00 AM EST",
        "11/30/1997 9:00 AM EST",
        "1/4/1998 9:00 AM EST",
        "1/25/1998 9:00 AM EST",
        "3/1/1998 9:00 AM EST",
        "3/29/1998 9:00 AM EST",
        "5/3/1998 9:00 AM EDT",
        "5/31/1998 9:00 AM EST"
      ]
      )

      # enumeration_spec(
      # "Monthly on the second to last Monday of the month for 6 months (RFC 2445 p 121)",
      # "19970922T090000",
      # "US-Eastern",
      # "FREQ=MONTHLY;COUNT=6;BYDAY=-2MO",
      # [
      #   "9/22/1997 9:00 AM EDT",
      #   "10/20/1997 9:00 AM EDT",
      #   "11/17/1997 9:00 AM EST",
      #   "12/22/1997 9:00 AM EST",
      #   "1/19/1998 9:00 AM EST",
      #   "2/16/1998 9:00 AM EST"
      # ]
      # )

      enumeration_spec(
      "Monthly on the third the to last day of the month forever (RFC 2445 p 121)",
      "19970928T090000",
      "US-Eastern",
      "FREQ=MONTHLY;BYMONTHDAY=-3",
      [
        "9/28/1997 9:00 AM EDT",
        "10/29/1997 9:00 AM EDT",
        "11/28/1997 9:00 AM EST",
        "12/29/1997 9:00 AM EST",
        "1/29/1998 9:00 AM EST",
        "2/26/1998 9:00 AM EST",
        "..."
      ]
      )

      enumeration_spec(
      "Monthly on the first and last day of the month for 10 occurrences (RFC 2445 p 121)",
      "19970930T090000",
      "US-Eastern",
      "FREQ=MONTHLY;COUNT=10;BYMONTHDAY=1,-1",
      [
        "9/30/1997 9:00 AM EDT",
        "10/1/1997 9:00 AM EDT",
        "10/31/1997 9:00 AM EST",
        "11/1/1997 9:00 AM EST",
        "11/30/1997 9:00 AM EST",
        "12/1/1997 9:00 AM EST",
        "12/31/1997 9:00 AM EST",
        "1/1/1998 9:00 AM EST",
        "1/31/1998 9:00 AM EST",
        "2/1/1998 9:00 AM EST"
      ]
      )

      enumeration_spec(
      "Every 18 months on the 10th thru 15th of the month for 10 occurrences (RFC 2445 p 121)",
      "19970910T090000",
      "US-Eastern",
      "FREQ=MONTHLY;INTERVAL=18;COUNT=10;BYMONTHDAY=10,11,12,13,14,15",
      [
        "9/10/1997 9:00 AM EDT",
        "9/11/1997 9:00 AM EDT",
        "9/12/1997 9:00 AM EDT",
        "9/13/1997 9:00 AM EDT",
        "9/14/1997 9:00 AM EDT",
        "9/15/1997 9:00 AM EDT",
        "3/10/1999 9:00 AM EDT",
        "3/11/1999 9:00 AM EDT",
        "3/12/1999 9:00 AM EDT",
        "3/13/1999 9:00 AM EDT"
      ]
      )

      enumeration_spec(
      "Every Tuesday, every other month (RFC 2445 p 122)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=MONTHLY;INTERVAL=2;BYDAY=TU",
      [
        "9/2/1997 9:00 AM EDT",
        "9/9/1997 9:00 AM EDT",
        "9/16/1997 9:00 AM EDT",
        "9/23/1997 9:00 AM EDT",
        "9/30/1997 9:00 AM EDT",
        "11/4/1997 9:00 AM EST",
        "11/11/1997 9:00 AM EST",
        "11/18/1997 9:00 AM EST",
        "11/25/1997 9:00 AM EST",
        "1/6/1998 9:00 AM EST",
        "1/13/1998 9:00 AM EST",
        "1/20/1998 9:00 AM EST",
        "1/27/1998 9:00 AM EST",
        "3/3/1998 9:00 AM EST",
        "3/10/1998 9:00 AM EST",
        "3/17/1998 9:00 AM EST",
        "3/24/1998 9:00 AM EST",
        "3/31/1998 9:00 AM EST",
        "..."
      ]
      )

      enumeration_spec(
      "Yearly in June and July for 10 occurrences (RFC 2445 p 122)",
      "19970610T090000",
      "US-Eastern",
      "FREQ=YEARLY;COUNT=10;BYMONTH=6,7",
      [
        "6/10/1997 9:00 AM EDT",
        "7/10/1997 9:00 AM EDT",
        "6/10/1998 9:00 AM EDT",
        "7/10/1998 9:00 AM EDT",
        "6/10/1999 9:00 AM EDT",
        "7/10/1999 9:00 AM EDT",
        "6/10/2000 9:00 AM EDT",
        "7/10/2000 9:00 AM EDT",
        "6/10/2001 9:00 AM EDT",
        "7/10/2001 9:00 AM EDT"
      ]
      )

      enumeration_spec(
      "Every other year on January, February, and March for 10 occurrences (RFC 2445 p 122)",
      "19970310T090000",
      "US-Eastern",
      "FREQ=YEARLY;INTERVAL=2;COUNT=10;BYMONTH=1,2,3",
      [
        "3/10/1997 9:00 AM EST",
        "1/10/1999 9:00 AM EST",
        "2/10/1999 9:00 AM EST",
        "3/10/1999 9:00 AM EST",
        "1/10/2001 9:00 AM EST",
        "2/10/2001 9:00 AM EST",
        "3/10/2001 9:00 AM EST",
        "1/10/2003 9:00 AM EST",
        "2/10/2003 9:00 AM EST",
        "3/10/2003 9:00 AM EST",
      ]
      )

      enumeration_spec(
      "Every 3rd year on the 1st, 100th and 200th day for 10 occurrences (RFC 2445 p 122)",
      "19970101T090000",
      "US-Eastern",
      "FREQ=YEARLY;INTERVAL=3;COUNT=10;BYYEARDAY=1,100,200",
      [
        "1/1/1997 9:00 AM EST",
        "4/10/1997 9:00 AM EDT",
        "7/19/1997 9:00 AM EDT",
        "1/1/2000 9:00 AM EST",
        "4/9/2000 9:00 AM EDT",
        "7/18/2000 9:00 AM EDT",
        "1/1/2003 9:00 AM EST",
        "4/10/2003 9:00 AM EDT",
        "7/19/2003 9:00 AM EDT",
        "1/1/2006 9:00 AM EST"
      ]
      )

      enumeration_spec(
      "Every 20th Monday of the year, forever (RFC 2445 p 122-3)",
      "19970519T090000",
      "US-Eastern",
      "FREQ=YEARLY;BYDAY=20MO",
      [
        "5/19/1997 9:00 AM EDT",
        "5/18/1998 9:00 AM EDT",
        "5/17/1999 9:00 AM EDT",
        "..."
      ]
      )

      enumeration_spec(
      "Every second to last Wednesday of the year, forever",
      "19971224T090000",
      "US-Eastern",
      "FREQ=YEARLY;BYDAY=-2WE",
      [
        "12/24/1997 9:00 AM EDT",
        "12/23/1998 9:00 AM EDT",
        "12/22/1999 9:00 AM EDT",
        "12/20/2000 9:00 AM EDT",
        "..."
      ]
      )

      enumeration_spec(
      "Monday of week number 20 (where the default start of the week is Monday), forever (RFC 2445 p 123)",
      "19970512T090000",
      "US-Eastern",
      "FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO",
      [
        "5/12/1997 9:00 AM EDT",
        "5/11/1998 9:00 AM EDT",
        "5/17/1999 9:00 AM EDT",
        "..."
      ]
      )
      
      enumeration_spec(
      "Every Thursday in March, forever (RFC 2445 p 123)",
      "19970313T090000",
      "US-Eastern",
      "FREQ=YEARLY;BYMONTH=3;BYDAY=TH",
      [
        "3/13/1997 9:00 AM EST",
        "3/20/1997 9:00 AM EST",
        "3/27/1997 9:00 AM EST",
        "3/5/1998 9:00 AM  EST",
        "3/12/1998 9:00 AM EST",
        "3/19/1998 9:00 AM EST",
        "3/26/1998 9:00 AM EST",
        "3/4/1999 9:00 AM  EST",
        "3/11/1999 9:00 AM EST",
        "3/18/1999 9:00 AM EST",
        "3/25/1999 9:00 AM EST",
        "..."
      ]
      )

      enumeration_spec(
      "Every Thursday, but only during June, July, and August, forever (RFC 2445 p 123)",
      "19970605T090000",
      "US-Eastern",
      "FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8",
      [
        "6/05/1997 9:00 AM EDT",
        "6/12/1997 9:00 AM EDT",
        "6/19/1997 9:00 AM EDT",
        "6/26/1997 9:00 AM EDT",
        "7/03/1997 9:00 AM EDT",
        "7/10/1997 9:00 AM EDT",
        "7/17/1997 9:00 AM EDT",
        "7/24/1997 9:00 AM EDT",
        "7/31/1997 9:00 AM EDT",
        "8/07/1997 9:00 AM EDT",
        "8/14/1997 9:00 AM EDT",
        "8/21/1997 9:00 AM EDT",
        "8/28/1997 9:00 AM EDT",
        "6/04/1998 9:00 AM EDT",
        "6/11/1998 9:00 AM EDT",
        "6/18/1998 9:00 AM EDT",
        "6/25/1998 9:00 AM EDT",
        "7/02/1998 9:00 AM EDT",
        "7/09/1998 9:00 AM EDT",
        "7/16/1998 9:00 AM EDT",
        "7/23/1998 9:00 AM EDT",
        "7/30/1998 9:00 AM EDT",
        "8/06/1998 9:00 AM EDT",
        "8/13/1998 9:00 AM EDT",
        "8/20/1998 9:00 AM EDT",
        "8/27/1998 9:00 AM EDT",
        "6/03/1999 9:00 AM EDT",
        "6/10/1999 9:00 AM EDT",
        "6/17/1999 9:00 AM EDT",
        "6/24/1999 9:00 AM EDT",
        "7/01/1999 9:00 AM EDT",
        "7/08/1999 9:00 AM EDT",
        "7/15/1999 9:00 AM EDT",
        "7/22/1999 9:00 AM EDT",
        "7/29/1999 9:00 AM EDT",
        "8/05/1999 9:00 AM EDT",
        "8/12/1999 9:00 AM EDT",
        "8/19/1999 9:00 AM EDT",
        "8/26/1999 9:00 AM EDT",
        "..."
      ]
      )

      # enumeration_spec(
      # "Every Friday the 13th, forever (RFC 2445 p 123-4)",
      # "19970902T090000",
      # "US-Eastern",
      # "FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13",
      # [
      #   # The RFC example uses exdate to exclude the start date, this is a slightly altered
      #   # use case
      #   "9/2/1997 9:00 AM EST",
      #   "2/13/1998 9:00 AM EST",
      #   "3/13/1998 9:00 AM EST",
      #   "11/13/1998 9:00 AM EST",
      #   "8/13/1999 9:00 AM EDT",
      #   "10/13/2000 9:00 AM EST",
      #   "..."
      # ]
      # )

      enumeration_spec(
      "The first Saturday that follows the first Sunday of the month, forever (RFC 2445 p 124)",
      "19970913T090000",
      "US-Eastern",
      "FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13",
      [
        "9/13/1997 9:00 AM EDT",
        "10/11/1997 9:00 AM EDT",
        "11/8/1997 9:00 AM EST",
        "12/13/1997 9:00 AM EST",
        "1/10/1998 9:00 AM EST",
        "2/7/1998 9:00 AM EST",
        "3/7/1998 9:00 AM EST",
        "4/11/1998 9:00 AM EDT",
        "5/9/1998 9:00 AM EDT",
        "6/13/1998 9:00 AM EDT",
        "..."
      ]
      )

      enumeration_spec(
      "Every four years, the first Tuesday after a Monday in November, forever(U.S. Presidential Election day) (RFC 2445 p 124)",
      "19961105T090000",
      "US-Eastern",
      "FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8",
      [
        "11/5/1996 9:00 AM EDT",
        "11/7/2000 9:00 AM EDT",
        "11/2/2004 9:00 AM EDT",
        "..."
      ]
      )

      enumeration_spec(
      "3rd instance into the month of one of Tuesday, Wednesday or Thursday, for the next 3 months (RFC 2445 p 124)",
      "19970904T090000",
      "US-Eastern",
      "FREQ=MONTHLY;COUNT=3;BYDAY=TU,WE,TH;BYSETPOS=3",
      [
        "9/4/1997 9:00 AM EDT",
        "10/7/1997 9:00 AM EDT",
        "11/6/1997 9:00 AM EST",
      ]
      )

      enumeration_spec(
      "The 2nd to last weekday of the month (RFC 2445 p 124)",
      "19970929T090000",
      "US-Eastern",
      "FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2",
      [
        "9/29/1997 9:00 AM EDT",
        "10/30/1997 9:00 AM EST",
        "11/27/1997 9:00 AM EST",
        "12/30/1997 9:00 AM EST",
        "1/29/1998 9:00 AM EST",
        "2/26/1998 9:00 AM EST",
        "3/30/1998 9:00 AM EST",
        "..."
      ]
      )

      enumeration_spec(
      "Every 3 hours from 9:00 AM to 5:00 PM on a specific day (RFC 2445 p 125)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=HOURLY;INTERVAL=3;UNTIL=19970902T170000Z",
      [
        "9/2/1997 9:00 EDT",
        "9/2/1997 12:00 EDT",
        "9/2/1997 15:00 EDT",
      ]
      )

      enumeration_spec(
      "Every 15 minutes for 6 occurrences (RFC 2445 p 125)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=MINUTELY;INTERVAL=15;COUNT=6",
      [
        "9/2/1997 09:00 EDT",
        "9/2/1997 09:15 EDT",
        "9/2/1997 09:30 EDT",
        "9/2/1997 09:45 EDT",
        "9/2/1997 10:00 EDT",
        "9/2/1997 10:15 EDT",
      ]
      )

      enumeration_spec(
      "Every hour and a half for 4 occurrences (RFC 2445 p 125)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=MINUTELY;INTERVAL=90;COUNT=4",
      [
        "9/2/1997 09:00 EDT",
        "9/2/1997 10:30 EDT",
        "9/2/1997 12:00 EDT",
        "9/2/1997 13:30 EDT",
      ]
      )

      enumeration_spec(
      "Every 20 minutes from 9:00 AM to 4:40 PM every day - alternative 1 (RFC 2445 p 125)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=DAILY;BYHOUR=9,10,11,12,13,14,15,16;BYMINUTE=0,20,40",
      [
        "9/2/1997 09:00 EDT",
        "9/2/1997 09:20 EDT",
        "9/2/1997 09:40 EDT",
        "9/2/1997 10:00 EDT",
        "9/2/1997 10:20 EDT",
        "9/2/1997 10:40 EDT",
        "9/2/1997 11:00 EDT",
        "9/2/1997 11:20 EDT",
        "9/2/1997 11:40 EDT",
        "9/2/1997 12:00 EDT",
        "9/2/1997 12:20 EDT",
        "9/2/1997 12:40 EDT",
        "9/2/1997 13:00 EDT",
        "9/2/1997 13:20 EDT",
        "9/2/1997 13:40 EDT",
        "9/2/1997 14:00 EDT",
        "9/2/1997 14:20 EDT",
        "9/2/1997 14:40 EDT",
        "9/2/1997 15:00 EDT",
        "9/2/1997 15:20 EDT",
        "9/2/1997 15:40 EDT",
        "9/2/1997 16:00 EDT",
        "9/2/1997 16:20 EDT",
        "9/2/1997 16:40 EDT",
        "9/3/1997 09:00 EDT",
        "9/3/1997 09:20 EDT",
        "9/3/1997 09:40 EDT",
        "9/3/1997 10:00 EDT",
        "9/3/1997 10:20 EDT",
        "9/3/1997 10:40 EDT",
        "9/3/1997 11:00 EDT",
        "9/3/1997 11:20 EDT",
        "9/3/1997 11:40 EDT",
        "9/3/1997 12:00 EDT",
        "9/3/1997 12:20 EDT",
        "9/3/1997 12:40 EDT",
        "9/3/1997 13:00 EDT",
        "9/3/1997 13:20 EDT",
        "9/3/1997 13:40 EDT",
        "9/3/1997 14:00 EDT",
        "9/3/1997 14:20 EDT",
        "9/3/1997 14:40 EDT",
        "9/3/1997 15:00 EDT",
        "9/3/1997 15:20 EDT",
        "9/3/1997 15:40 EDT",
        "9/3/1997 16:00 EDT",
        "9/3/1997 16:20 EDT",
        "9/3/1997 16:40 EDT",
        "..."
      ]
      )

      enumeration_spec(
      "Every 20 minutes from 9:00 AM to 4:40 PM every day - alternative 2 (RFC 2445 p 125)",
      "19970902T090000",
      "US-Eastern",
      "FREQ=MINUTELY;INTERVAL=20;BYHOUR=9,10,11,12,13,14,15,16",
      [
        "9/2/1997 09:00 EDT",
        "9/2/1997 09:20 EDT",
        "9/2/1997 09:40 EDT",
        "9/2/1997 10:00 EDT",
        "9/2/1997 10:20 EDT",
        "9/2/1997 10:40 EDT",
        "9/2/1997 11:00 EDT",
        "9/2/1997 11:20 EDT",
        "9/2/1997 11:40 EDT",
        "9/2/1997 12:00 EDT",
        "9/2/1997 12:20 EDT",
        "9/2/1997 12:40 EDT",
        "9/2/1997 13:00 EDT",
        "9/2/1997 13:20 EDT",
        "9/2/1997 13:40 EDT",
        "9/2/1997 14:00 EDT",
        "9/2/1997 14:20 EDT",
        "9/2/1997 14:40 EDT",
        "9/2/1997 15:00 EDT",
        "9/2/1997 15:20 EDT",
        "9/2/1997 15:40 EDT",
        "9/2/1997 16:00 EDT",
        "9/2/1997 16:20 EDT",
        "9/2/1997 16:40 EDT",
        "9/3/1997 09:00 EDT",
        "9/3/1997 09:20 EDT",
        "9/3/1997 09:40 EDT",
        "9/3/1997 10:00 EDT",
        "9/3/1997 10:20 EDT",
        "9/3/1997 10:40 EDT",
        "9/3/1997 11:00 EDT",
        "9/3/1997 11:20 EDT",
        "9/3/1997 11:40 EDT",
        "9/3/1997 12:00 EDT",
        "9/3/1997 12:20 EDT",
        "9/3/1997 12:40 EDT",
        "9/3/1997 13:00 EDT",
        "9/3/1997 13:20 EDT",
        "9/3/1997 13:40 EDT",
        "9/3/1997 14:00 EDT",
        "9/3/1997 14:20 EDT",
        "9/3/1997 14:40 EDT",
        "9/3/1997 15:00 EDT",
        "9/3/1997 15:20 EDT",
        "9/3/1997 15:40 EDT",
        "9/3/1997 16:00 EDT",
        "9/3/1997 16:20 EDT",
        "9/3/1997 16:40 EDT",
        "..."
      ]
      )

      enumeration_spec(
      "An example where the days generated makes a difference because of WKST (MO case) (RFC 2445 p 125)",
      "19970805T090000",
      "US-Eastern",
      "FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=MO",
      [
        "8/05/1997 09:00 EDT",
        "8/10/1997 09:00 EDT",
        "8/19/1997 09:00 EDT",
        "8/24/1997 09:00 EDT"
      ]
      )

      enumeration_spec(
      "An example where the days generated makes a difference because of WKST (MO case) (RFC 2445 p 125)",
      "19970805T090000",
      "US-Eastern",
      "FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU;WKST=SU",
      [
        "8/05/1997 09:00 EDT",
        "8/17/1997 09:00 EDT",
        "8/19/1997 09:00 EDT",
        "8/31/1997 09:00 EDT"
      ]
      )
    end
  end

describe RiCal::PropertyValue::RecurrenceRule::RecurringDay do
  
  def recurring(day)
    RiCal::PropertyValue::RecurrenceRule::RecurringDay.new(day, RiCal::PropertyValue::RecurrenceRule.new(:value => "FREQ=MONTHLY"))
  end
    
  describe "MO - any monday" do
    before(:each) do
      @it= recurring("MO")
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
      @it= recurring("TU")
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
      @it= recurring("WE")
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
      @it= recurring("TH")
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
      @it= recurring("FR")
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
      @it= recurring("SA")
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
      @it= recurring("SU")
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
      @it = recurring("1MO")
    end

    it "should match the first Monday of the month" do
      @it.should include(Date.parse("Nov 3 2008"))
    end

    it "should not include other Mondays" do
      [10, 17, 24].each do |day|
        @it.should_not include(Date.parse("Nov #{day} 2008"))
      end
    end
  end

  describe "5MO - Fifth Monday" do
    before(:each) do
      @it = recurring("5MO")
    end

    it "should match the fifth Monday of a month with five Mondays" do
      @it.should include(Date.parse("Dec 29 2008"))
    end
  end

  describe "-1MO - last Monday" do
    before(:each) do
      @it = recurring("-1MO")
    end

    it "should match the last Monday of the month" do
      @it.should include(Date.parse("Dec 29 2008"))
    end

    it "should not include other Mondays" do
      [1, 8, 15, 22].each do |day|
        @it.should_not include(Date.parse("Dec #{day} 2008"))
      end
    end

    it "should match February 28 for a non leap year when appropriate" do
      @it.should include(Date.parse("Feb 28 2005"))
    end

    it "should match February 29 for a non leap year when appropriate" do
      @it.should include(Date.parse("Feb 29 1988"))
    end
  end
end

describe RiCal::PropertyValue::RecurrenceRule::RecurringMonthDay do

  describe "with a value of 1" do
    before(:each) do
      @it = RiCal::PropertyValue::RecurrenceRule::RecurringMonthDay.new(1)
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
          @it = RiCal::PropertyValue::RecurrenceRule::RecurringMonthDay.new(-1)
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

describe RiCal::PropertyValue::RecurrenceRule::RecurringYearDay do

  describe "with a value of 20" do
    before(:each) do
      @it = RiCal::PropertyValue::RecurrenceRule::RecurringYearDay.new(20)
    end

    it "should include January 20 in a non-leap year" do
      @it.should include(Date.new(2007, 1, 20))
    end

    it "should include January 20 in a leap year" do
      @it.should include(Date.new(2008, 1, 20))
    end
  end

  describe "with a value of 60" do
    before(:each) do
      @it = RiCal::PropertyValue::RecurrenceRule::RecurringYearDay.new(60)
    end

    it "should include March 1 in a non-leap year" do
      @it.should include(Date.new(2007, 3, 1))
    end

    it "should include February 29 in a leap year" do
      @it.should include(Date.new(2008, 2, 29))
    end
  end

  describe "with a value of -1" do
    before(:each) do
      @it = RiCal::PropertyValue::RecurrenceRule::RecurringYearDay.new(-1)
    end

    it "should include December 31 in a non-leap year" do
      @it.should include(Date.new(2007,12, 31))
    end

    it "should include December 31 in a leap year" do
      @it.should include(Date.new(2008,12, 31))
    end
  end

  describe "with a value of -365" do
    before(:each) do
      @it = RiCal::PropertyValue::RecurrenceRule::RecurringYearDay.new(-365)
    end

    it "should include January 1 in a non-leap year" do
      @it.should include(Date.new(2007,1, 1))
    end

    it "should include January 2 in a leap year" do
      @it.should include(Date.new(2008,1, 2))
    end
  end

  describe "with a value of -366" do
    before(:each) do
      @it = RiCal::PropertyValue::RecurrenceRule::RecurringYearDay.new(-366)
    end

    it "should not include January 1 in a non-leap year" do
      @it.should_not include(Date.new(2007,1, 1))
    end

    it "should include January 1 in a leap year" do
      @it.should include(Date.new(2008,1, 1))
    end
  end
end

describe RiCal::PropertyValue::RecurrenceRule::RecurringNumberedWeek do
  before(:each) do
    @it = RiCal::PropertyValue::RecurrenceRule::RecurringNumberedWeek.new(50)
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
