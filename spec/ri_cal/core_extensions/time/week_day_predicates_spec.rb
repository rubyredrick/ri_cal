require File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper])

describe RiCal::CoreExtensions::Time::WeekDayPredicates do
  
  describe ".nth_wday_in_month" do
    it "should return Feb 28, 2005 for the 4th Monday for a date in February 2005" do
      expected = RiCal::PropertyValue::Date.new(:value => "20050228")
      it =Date.parse("Feb 7, 2005").nth_wday_in_month(4, 1)
      it.should == expected
    end
  end
  
  describe ".nth_wday_in_month?" do
    it "should return true for Feb 28, 2005 for the 4th Monday" do
      Date.parse("Feb 28, 2005").nth_wday_in_month?(4, 1).should be
    end
  end
end
