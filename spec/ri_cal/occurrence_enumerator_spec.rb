#- ©2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license

require File.join(File.dirname(__FILE__), %w[.. spec_helper.rb])

def mock_enumerator(name, next_occurrence)
  mock(name, :next_occurrence => next_occurrence, :bounded? => true, :empty? => false)
end

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

 Fr13UnboundedZuluExpectedFive = [
   "19980213T090000Z",
   "19980313T090000Z",
   "19981113T090000Z",
   "19990813T090000Z",
   "20001013T090000Z"
   ].map {|start| src = <<-TEXT
BEGIN:VEVENT
DTSTART:#{start}
RECURRENCE-ID:#{start}
END:VEVENT
TEXT
          RiCal.parse_string(src).first
        }

  describe ".occurrences" do
    describe "with an unbounded component" do
      before(:each) do
        @it = RiCal.parse_string(Fr13Unbounded_Zulu).first
      end
      
      it "should raise an ArgumentError with no options to limit result" do
        lambda {@it.occurrences}.should raise_error(ArgumentError)
      end
      
      it "should have the right five occurrences when :count => 5 option is used" do
        result = @it.occurrences(:count => 5)
        result.should == Fr13UnboundedZuluExpectedFive
      end
      
    end
  end
  
  describe ".occurrences" do
    before(:each) do
      @it = RiCal.parse_string(Fr13Unbounded_Zulu).first
    end
    
    describe "with :starting specified" do
      it "should exclude dates before :starting" do
        result = @it.occurrences(:starting => Fr13UnboundedZuluExpectedFive[1].dtstart,
                                 :before   => Fr13UnboundedZuluExpectedFive[-1].dtstart)
        result.map{|o|o.dtstart}.should == Fr13UnboundedZuluExpectedFive[1..-2].map{|e| e.dtstart}
      end
    end
    
    describe "with :before specified" do
      it "should exclude dates after :before" do
        result = @it.occurrences(:before => Fr13UnboundedZuluExpectedFive[3].dtstart,
                                 :count => 5)
        result.map{|o|o.dtstart}.should == Fr13UnboundedZuluExpectedFive[0..2].map{|e| e.dtstart}
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
          @result << occurrence
        end
      end

      it "should have the right first six occurrences" do
        # TODO - Need to properly deal with timezones
        @result.should == Fr13UnboundedZuluExpectedFive
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
        @enum1 = mock_enumerator("rrule_enumerator1", :occ1)
        @enum2 = mock_enumerator("rrule_enumerator2", :occ2)
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
        @enum1 = mock_enumerator("rrule_enumerator1",3)
        @enum2 = mock_enumerator("rrule_enumerator2", 2)
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
        @enum1 = mock_enumerator("rrule_enumerator1", 2)
        @enum2 = mock_enumerator("rrule_enumerator2", 2)
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
        @enum1 = mock_enumerator("rrule_enumerator1", nil)
        @enum2 = mock_enumerator("rrule_enumerator2", nil)
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
  
    context "Bug report from paulsm" do
        before(:each) do
          cals = RiCal.parse_string <<ENDCAL
BEGIN:VCALENDAR
X-WR-TIMEZONE:America/New_York
PRODID:-//Apple Inc.//iCal 3.0//EN
CALSCALE:GREGORIAN
X-WR-CALNAME:test
VERSION:2.0
X-WR-RELCALID:1884C7F8-BC8E-457F-94AC-297871967D5E
X-APPLE-CALENDAR-COLOR:#2CA10B
BEGIN:VTIMEZONE
TZID:US/Eastern
BEGIN:DAYLIGHT
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
DTSTART:20070311T020000
RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU
TZNAME:EDT
END:DAYLIGHT
BEGIN:STANDARD
TZOFFSETFROM:-0400
TZOFFSETTO:-0500
DTSTART:20071104T020000
RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU
TZNAME:EST
END:STANDARD
END:VTIMEZONE
BEGIN:VEVENT
SEQUENCE:5
TRANSP:OPAQUE
UID:00481E53-9258-4EA7-9F8D-947D3041A3F2
DTSTART;TZID=US/Eastern:20090224T090000
DTSTAMP:20090225T000908Z
SUMMARY:Test Event
CREATED:20090225T000839Z
DTEND;TZID=US/Eastern:20090224T100000
RRULE:FREQ=DAILY;INTERVAL=1;UNTIL=20090228T045959Z
END:VEVENT
END:VCALENDAR
ENDCAL
        @event = cals.first.events.first
      end


      it "the event should be enumerable" do
        lambda {@event.occurrences}.should_not raise_error
      end
    end

    context "Lighthouse bug #3" do
      before(:each) do
        cals = RiCal.parse_string <<ENDCAL
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Mozilla.org/NONSGML Mozilla Calendar V1.1//EN
BEGIN:VTIMEZONE
TZID:/mozilla.org/20070129_1/Europe/Paris
X-LIC-LOCATION:Europe/Paris
BEGIN:DAYLIGHT
TZOFFSETFROM:+0100
TZOFFSETTO:+0200
TZNAME:CEST
DTSTART:19700329T020000
RRULE:FREQ=YEARLY;INTERVAL=1;BYDAY=-1SU;BYMONTH=3
END:DAYLIGHT
BEGIN:STANDARD
TZOFFSETFROM:+0200
TZOFFSETTO:+0100
TZNAME:CET
DTSTART:19701025T030000
RRULE:FREQ=YEARLY;INTERVAL=1;BYDAY=-1SU;BYMONTH=10
END:STANDARD
END:VTIMEZONE
BEGIN:VEVENT
CREATED:20070606T141629Z
LAST-MODIFIED:20070606T154611Z
DTSTAMP:20070607T120859Z
UID:5d1ae55f-3910-4de9-8b65-d652768fb2f2
SUMMARY:Lundi de Pâques
DTSTART;VALUE=DATE;TZID=/mozilla.org/20070129_1/Europe/Paris:20070409
DTEND;VALUE=DATE;TZID=/mozilla.org/20070129_1/Europe/Paris:20070410
CATEGORIES:Jours fériés
END:VEVENT
END:VCALENDAR
ENDCAL
      @event = cals.first.events.first
    end
    
    it "should be able to enumerate occurrences" do
      @event.occurrences.should == [@event]
    end
  end

end
