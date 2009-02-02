require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::Vevent do

  describe "with both dtend and duration specified" do
    before(:each) do
      @it = RiCal::Vevent.parse_string("BEGIN:VEVENT\nDTEND:19970903T190000Z\nDURATION:H1\nEND:VEVENT").first
    end

    it "should be invalid" do
      @it.should_not be_valid
    end
  end
end