require File.join(File.dirname(__FILE__), %w[.. spec_helper])

# Note that this is more of a functional spec
describe RiCal::OccurrenceEnumerator do
  
  Fr13Unbounded_Zulu = <<-TEXT
BEGIN:VEVENT
DTSTART:19970902T090000Z
EXDATE:19970902T090000Z
RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13
END:VEVENT
TEXT

 Fr13Unbounded_Eastern = <<-TEXT
BEGIN:VEVENT
DTSTART;TZID=US-Eastern:19970902T090000
EXDATE;TZID=US-Eastern:19970902T090000
RRULE:FREQ=MONTHLY;BYDAY=FR;BYMONTHDAY=13
END:VEVENT
TEXT
  
  describe ".occurrences" do
    describe "with an unbounded component" do
      before(:each) do
        @it = RiCal.parse_string(Fr13Unbounded_Zulu).first
        @expected_five = [
          "2/13/1998 9:00 AM  UTC",
          "3/13/1998 9:00 AM  UTC",
          "11/13/1998 9:00 AM UTC",
          "8/13/1999 9:00 AM  UTC",
          "10/13/2000 9:00 AM UTC",
          ].map {|s| DateTime.parse(s)}
      end
      
      it "should raise an ArgumentError with no options to limit result" do
        lambda {@it.occurrences}.should raise_error(ArgumentError)
      end
      
      it "should have the right five occurrences when :count => 5 option is used" do
        @it.occurrences(:count => 5).map {|occ| occ[:start].to_ruby_value}.should == @expected_five
      end
      
    end
  end
    

  describe ".each" do
    describe " for Every Friday the 13th, forever" do
      before(:each) do
        event = RiCal.parse_string(Fr13Unbounded_Zulu).first
        @result = []
        event.each do |occurrence|
          break if @result.length >= 5
          @result << occurrence[:start].to_ruby_value
        end
      end

      it "should have the right first six occurrences" do
        # TODO - Need to properly deal with timezones
        expected = [
          # "2/13/1998 9:00 AM EST",
          # "3/13/1998 9:00 AM EST",
          # "11/13/1998 9:00 AM EST",
          # "8/13/1999 9:00 AM EDT",
          # "10/13/2000 9:00 AM EST",
          "2/13/1998 9:00 AM  UTC",
          "3/13/1998 9:00 AM  UTC",
          "11/13/1998 9:00 AM UTC",
          "8/13/1999 9:00 AM  UTC",
          "10/13/2000 9:00 AM UTC",
          ].map {|s| DateTime.parse(s)}
        @result.should == expected
      end

    end
  end
end

describe RiCal::OccurrenceEnumerator::OccurrenceMerger do
  before(:each) do
    @merger = RiCal::OccurrenceEnumerator::OccurrenceMerger
  end
  
  describe ".for" do
    it "should return an EmptyEnumerator if the rules parameter is nil" do
      @merger.for(nil, nil).should == RiCal::OccurrenceEnumerator::EmptyRulesEnumerator
    end

    it "should return an EmptyEnumerator if the rules parameter is empty" do
      @merger.for(nil, []).should == RiCal::OccurrenceEnumerator::EmptyRulesEnumerator
    end
    
    describe "with a single rrule" do
      before(:each) do
        @component = mock("component", :dtstart => :dtstart_value)
        @rrule = mock("rrule", :enumerator => :rrule_enumerator)
      end
      
      it "should return the enumerator the rrule" do
        @merger.for(@component, [@rrule]).should == :rrule_enumerator
      end
      
      it "should pass the component to the enumerator instantiation" do
        @rrule.should_receive(:enumerator).with(@component)
        @merger.for(@component, [@rrule])
      end
    end
    
    describe "with multiple rrules" do
      before(:each) do
        @component = mock("component", :dtstart => :dtstart_value)
        @enum1 = mock("rrule_enumerator1", :next_occurrence => :occ1, :bounded? => true)
        @enum2 = mock("rrule_enumerator2", :next_occurrence => :occ2, :bounded? => true)
        @rrule1 = mock("rrule", :enumerator => @enum1)
        @rrule2 = mock("rrule", :enumerator => @enum2)
      end
      
      it "should return an instance of RiCal::OccurrenceEnumerator::OccurrenceMerger" do
        @merger.for(@component, [@rrule1, @rrule2]).should be_kind_of(RiCal::OccurrenceEnumerator::OccurrenceMerger)
      end
      
      it "should pass the component to the enumerator instantiation" do
        @rrule1.should_receive(:enumerator).with(@component).and_return(@enum1)
        @rrule2.should_receive(:enumerator).with(@component).and_return(@enum2)
        @merger.for(@component, [@rrule1, @rrule2])
      end
      
      it "should preload the next occurrences" do
        @enum1.should_receive(:next_occurrence).and_return(:occ1)
        @enum2.should_receive(:next_occurrence).and_return(:occ2)
        @merger.for(@component, [@rrule1, @rrule2])        
      end
    end
  end
  
  describe "#next_occurence" do

    describe "with unique nexts" do
      before(:each) do
        @enum1 = mock("rrule_enumerator1", :next_occurrence => 3, :bounded? => true)
        @enum2 = mock("rrule_enumerator2", :next_occurrence => 2, :bounded? => true)
        @rrule1 = mock("rrule", :enumerator => @enum1)
        @rrule2 = mock("rrule", :enumerator => @enum2)
        @it = @merger.new(0, [@rrule1, @rrule2])
      end
      
      it "should return the earliest occurrence" do
        @it.next_occurrence.should == 2
      end
      
      it "should advance the enumerator which returned the result" do
        @enum2.should_receive(:next_occurrence).and_return(4)
        @it.next_occurrence
      end
      
      it "should not advance the other enumerator" do
        @enum1.should_not_receive(:next_occurrence)
        @it.next_occurrence
      end
      
      it "should properly update the next array" do
        @enum2.stub!(:next_occurrence).and_return(4)
        @it.next_occurrence
        @it.nexts.should == [3, 4]
      end
    end
    
    describe "with duplicated nexts" do
      before(:each) do
        @enum1 = mock("rrule_enumerator1", :next_occurrence => 2, :bounded? => true)
        @enum2 = mock("rrule_enumerator2", :next_occurrence => 2, :bounded? => true)
        @rrule1 = mock("rrule", :enumerator => @enum1)
        @rrule2 = mock("rrule", :enumerator => @enum2)
        @it = @merger.new(0, [@rrule1, @rrule2])
      end
      
      it "should return the earliest occurrence" do
        @it.next_occurrence.should == 2
      end
      
      it "should advance both enumerators" do
        @enum1.should_receive(:next_occurrence).and_return(5)
        @enum2.should_receive(:next_occurrence).and_return(4)
        @it.next_occurrence
      end
      
      it "should properly update the next array" do
        @enum1.stub!(:next_occurrence).and_return(5)
        @enum2.stub!(:next_occurrence).and_return(4)
        @it.next_occurrence
        @it.nexts.should == [5, 4]
      end
      
    end
    
    describe "with all enumerators at end" do
      before(:each) do
        @enum1 = mock("rrule_enumerator1", :next_occurrence => nil, :bounded? => true)
        @enum2 = mock("rrule_enumerator2", :next_occurrence => nil, :bounded? => true)
        @rrule1 = mock("rrule", :enumerator => @enum1)
        @rrule2 = mock("rrule", :enumerator => @enum2)
        @it = @merger.new(0, [@rrule1, @rrule2])
      end
      
      it "should return nil" do
        @it.next_occurrence.should == nil
      end
      
      it "should not advance the enumerators which returned the result" do
        @enum1.should_not_receive(:next_occurrence)
        @enum2.should_not_receive(:next_occurrence)
        @it.next_occurrence
      end
    end
  end
end
  
  
