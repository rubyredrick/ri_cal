require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RiCal::OccurrenceEnumerator do
  
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
        @enum1 = mock("rrule_enumerator1", :next_occurrence => :occ1)
        @enum2 = mock("rrule_enumerator2", :next_occurrence => :occ2)
        @rrule1 = mock("rrule", :enumerator => @enum1)
        @rrule2 = mock("rrule", :enumerator => @enum2)
      end
      
      it "should return an instance of RiCal::OccurrenceEnumerator::OccurrenceMerger" do
        @merger.for(@component, [@rrule1, @rrule2]).should be_kind_of RiCal::OccurrenceEnumerator::OccurrenceMerger
      end
      
      it "should pass the component to the enumerator instantiation" do
        @rrule1.should_receive(:enumerator).with(@component)
        @rrule2.should_receive(:enumerator).with(@component)
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
        @enum1 = mock("rrule_enumerator1", :next_occurrence => 3)
        @enum2 = mock("rrule_enumerator2", :next_occurrence => 2)
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
        @enum1 = mock("rrule_enumerator1", :next_occurrence => 2)
        @enum2 = mock("rrule_enumerator2", :next_occurrence => 2)
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
        @enum1 = mock("rrule_enumerator1", :next_occurrence => nil)
        @enum2 = mock("rrule_enumerator2", :next_occurrence => nil)
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
  
  
