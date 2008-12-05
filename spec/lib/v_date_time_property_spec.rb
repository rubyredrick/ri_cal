require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require File.join(File.dirname(__FILE__), %w[.. .. lib v_date_time_property])

describe RiCal::VDateTimeProperty do

  describe ".from_separated_line" do
    it "should return a VDateProperty if the value doesn't contain a time specification" do
      RiCal::VDateTimeProperty.from_separated_line(:name => "dtstart", :value => "19970714").should be_kind_of(RiCal::VDateProperty)
    end

    it "should return a VDateTimeProperty if the value does contain a time specification" do
      RiCal::VDateTimeProperty.from_separated_line(:name => "dtstart", :value => "19980118T230000").should be_kind_of(RiCal::VDateTimeProperty)
    end
  end

end