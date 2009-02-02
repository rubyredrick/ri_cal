require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::DateTimeValue do

  describe ".from_separated_line" do
    it "should return a DateValue if the value doesn't contain a time specification" do
      RiCal::DateTimeValue.from_separated_line(:name => "dtstart", :value => "19970714").should be_kind_of(RiCal::DateValue)
    end

    it "should return a DateTimeValue if the value does contain a time specification" do
      RiCal::DateTimeValue.from_separated_line(:name => "dtstart", :value => "19980118T230000").should be_kind_of(RiCal::DateTimeValue)
    end
  end

end