module RiCal
  # 
  class Vevent < Ventity
    # BEGIN GENERATED ATTRIBUTE CODE

    # return the the CLASS property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.8.1.3 pp 79-80
    def class_property
      @class_property ||= []
    end

    # set the the CLASS property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def class_property=(property_values)
      class_property = property_value
    end

    # return the value of the CLASS property
    # which will be an instance of String
    def security_class
      class_property.value
    end

    # set the value of the CLASS property
    def security_class=(*ruby_values)
      class_property= TextValue.convert(ruby_val)
    end

    attr_accessor :class_property

    def class_property_from_string(line) # :nodoc:
      @class_property = TextValue.new(line)
    end


    # return the the CREATED property
    # which will be an instances of RiCal::DateTimeValue
    # see RFC 2445 4.8.7.1 pp 129-130
    def created_property
      @created_property ||= []
    end

    # set the the CREATED property
    # property_value should be an instance of RiCal::DateTimeValue may be passed to this method
    def created_property=(property_values)
      created_property = property_value
    end

    # return the value of the CREATED property
    # which will be an instance of DateTime
    def created
      created_property.value
    end

    # set the value of the CREATED property
    def created=(*ruby_values)
      created_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :created_property

    def created_property_from_string(line) # :nodoc:
      @created_property = DateTimeValue.new(line)
    end


    # return the the DESCRIPTION property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.8.1.5 pp 81-82
    def description_property
      @description_property ||= []
    end

    # set the the DESCRIPTION property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def description_property=(property_values)
      description_property = property_value
    end

    # return the value of the DESCRIPTION property
    # which will be an instance of String
    def description
      description_property.value
    end

    # set the value of the DESCRIPTION property
    def description=(*ruby_values)
      description_property= TextValue.convert(ruby_val)
    end

    attr_accessor :description_property

    def description_property_from_string(line) # :nodoc:
      @description_property = TextValue.new(line)
    end


    # return the the DTSTART property
    # which will be an instances of either RiCal::DateTimeValue or RiCall::DateValue
    # see RFC 2445 4.8.2.4 pp 93-94
    def dtstart_property
      @dtstart_property ||= []
    end

    # set the the DTSTART property
    # property_value should be an instance of either RiCal::DateTimeValue or RiCall::DateValue may be passed to this method
    def dtstart_property=(property_values)
      dtstart_property = property_value
    end

    # return the value of the DTSTART property
    # which will be an instance of either DateTime or Date
    def dtstart
      dtstart_property.value
    end

    # set the value of the DTSTART property
    def dtstart=(*ruby_values)
      dtstart_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :dtstart_property

    def dtstart_property_from_string(line) # :nodoc:
      @dtstart_property = DateTimeValue.from_separated_line(line)
    end


    # return the the GEO property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.8.1.6 pp 82-83
    def geo_property
      @geo_property ||= []
    end

    # set the the GEO property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def geo_property=(property_values)
      geo_property = property_value
    end

    # return the value of the GEO property
    # which will be an instance of String
    def geo
      geo_property.value
    end

    # set the value of the GEO property
    def geo=(*ruby_values)
      geo_property= TextValue.convert(ruby_val)
    end

    attr_accessor :geo_property

    def geo_property_from_string(line) # :nodoc:
      @geo_property = TextValue.new(line)
    end


    # return the the LAST-MODIFIED property
    # which will be an instances of RiCal::DateTimeValue
    # see RFC 2445 4.8.7.3 p 131
    def last_modified_property
      @last_modified_property ||= []
    end

    # set the the LAST-MODIFIED property
    # property_value should be an instance of RiCal::DateTimeValue may be passed to this method
    def last_modified_property=(property_values)
      last_modified_property = property_value
    end

    # return the value of the LAST-MODIFIED property
    # which will be an instance of DateTime
    def last_modified
      last_modified_property.value
    end

    # set the value of the LAST-MODIFIED property
    def last_modified=(*ruby_values)
      last_modified_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :last_modified_property

    def last_modified_property_from_string(line) # :nodoc:
      @last_modified_property = DateTimeValue.new(line)
    end


    # return the the LOCATION property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.8.1.7 pp 84
    def location_property
      @location_property ||= []
    end

    # set the the LOCATION property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def location_property=(property_values)
      location_property = property_value
    end

    # return the value of the LOCATION property
    # which will be an instance of String
    def location
      location_property.value
    end

    # set the value of the LOCATION property
    def location=(*ruby_values)
      location_property= TextValue.convert(ruby_val)
    end

    attr_accessor :location_property

    def location_property_from_string(line) # :nodoc:
      @location_property = TextValue.new(line)
    end


    # return the the ORGANIZER property
    # which will be an instances of RiCal::CalAddressValue
    # see RFC 2445 4.8.4.3 pp 106-107
    def organizer_property
      @organizer_property ||= []
    end

    # set the the ORGANIZER property
    # property_value should be an instance of RiCal::CalAddressValue may be passed to this method
    def organizer_property=(property_values)
      organizer_property = property_value
    end

    # return the value of the ORGANIZER property
    # which will be an instance of CalAddress
    def organizer
      organizer_property.value
    end

    # set the value of the ORGANIZER property
    def organizer=(*ruby_values)
      organizer_property= CalAddressValue.convert(ruby_val)
    end

    attr_accessor :organizer_property

    def organizer_property_from_string(line) # :nodoc:
      @organizer_property = CalAddressValue.new(line)
    end


    # return the the PRIORITY property
    # which will be an instances of RiCal::IntegerValue
    # see RFC 2445 4.8.1.9 pp 85-87
    def priority_property
      @priority_property ||= []
    end

    # set the the PRIORITY property
    # property_value should be an instance of RiCal::IntegerValue may be passed to this method
    def priority_property=(property_values)
      priority_property = property_value
    end

    # return the value of the PRIORITY property
    # which will be an instance of Integer
    def priority
      priority_property.value
    end

    # set the value of the PRIORITY property
    def priority=(*ruby_values)
      priority_property= IntegerValue.convert(ruby_val)
    end

    attr_accessor :priority_property

    def priority_property_from_string(line) # :nodoc:
      @priority_property = IntegerValue.new(line)
    end


    # return the the DTSTAMP property
    # which will be an instances of RiCal::DateTimeValue
    # see RFC 2445 4.8.7.2 pp 130-131
    def dtstamp_property
      @dtstamp_property ||= []
    end

    # set the the DTSTAMP property
    # property_value should be an instance of RiCal::DateTimeValue may be passed to this method
    def dtstamp_property=(property_values)
      dtstamp_property = property_value
    end

    # return the value of the DTSTAMP property
    # which will be an instance of DateTime
    def dtstamp
      dtstamp_property.value
    end

    # set the value of the DTSTAMP property
    def dtstamp=(*ruby_values)
      dtstamp_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :dtstamp_property

    def dtstamp_property_from_string(line) # :nodoc:
      @dtstamp_property = DateTimeValue.new(line)
    end


    # return the the SEQUENCE property
    # which will be an instances of RiCal::IntegerValue
    # see RFC 2445 4.8.7.4 pp 131-133
    def sequence_property
      @sequence_property ||= []
    end

    # set the the SEQUENCE property
    # property_value should be an instance of RiCal::IntegerValue may be passed to this method
    def sequence_property=(property_values)
      sequence_property = property_value
    end

    # return the value of the SEQUENCE property
    # which will be an instance of Integer
    def sequence
      sequence_property.value
    end

    # set the value of the SEQUENCE property
    def sequence=(*ruby_values)
      sequence_property= IntegerValue.convert(ruby_val)
    end

    attr_accessor :sequence_property

    def sequence_property_from_string(line) # :nodoc:
      @sequence_property = IntegerValue.new(line)
    end


    # return the the STATUS property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.8.1.11 pp 80-89
    def status_property
      @status_property ||= []
    end

    # set the the STATUS property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def status_property=(property_values)
      status_property = property_value
    end

    # return the value of the STATUS property
    # which will be an instance of String
    def status
      status_property.value
    end

    # set the value of the STATUS property
    def status=(*ruby_values)
      status_property= TextValue.convert(ruby_val)
    end

    attr_accessor :status_property

    def status_property_from_string(line) # :nodoc:
      @status_property = TextValue.new(line)
    end


    # return the the SUMMARY property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.8.1.12 pp 89-90
    def summary_property
      @summary_property ||= []
    end

    # set the the SUMMARY property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def summary_property=(property_values)
      summary_property = property_value
    end

    # return the value of the SUMMARY property
    # which will be an instance of String
    def summary
      summary_property.value
    end

    # set the value of the SUMMARY property
    def summary=(*ruby_values)
      summary_property= TextValue.convert(ruby_val)
    end

    attr_accessor :summary_property

    def summary_property_from_string(line) # :nodoc:
      @summary_property = TextValue.new(line)
    end


    # return the the TRANSP property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.8.2.7 pp 96-97
    def transp_property
      @transp_property ||= []
    end

    # set the the TRANSP property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def transp_property=(property_values)
      transp_property = property_value
    end

    # return the value of the TRANSP property
    # which will be an instance of String
    def transp
      transp_property.value
    end

    # set the value of the TRANSP property
    def transp=(*ruby_values)
      transp_property= TextValue.convert(ruby_val)
    end

    attr_accessor :transp_property

    def transp_property_from_string(line) # :nodoc:
      @transp_property = TextValue.new(line)
    end


    # return the the UID property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.8.4.7 pp 111-112
    def uid_property
      @uid_property ||= []
    end

    # set the the UID property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def uid_property=(property_values)
      uid_property = property_value
    end

    # return the value of the UID property
    # which will be an instance of String
    def uid
      uid_property.value
    end

    # set the value of the UID property
    def uid=(*ruby_values)
      uid_property= TextValue.convert(ruby_val)
    end

    attr_accessor :uid_property

    def uid_property_from_string(line) # :nodoc:
      @uid_property = TextValue.new(line)
    end


    # return the the URL property
    # which will be an instances of RiCal::UriValue
    # see RFC 2445 4.8.4.6 pp 110-111
    def url_property
      @url_property ||= []
    end

    # set the the URL property
    # property_value should be an instance of RiCal::UriValue may be passed to this method
    def url_property=(property_values)
      url_property = property_value
    end

    # return the value of the URL property
    # which will be an instance of Uri
    def url
      url_property.value
    end

    # set the value of the URL property
    def url=(*ruby_values)
      url_property= UriValue.convert(ruby_val)
    end

    attr_accessor :url_property

    def url_property_from_string(line) # :nodoc:
      @url_property = UriValue.new(line)
    end


    # return the the RECURRENCE-ID property
    # which will be an instances of either RiCal::DateTimeValue or RiCall::DateValue
    # see RFC 2445 4.8.4.4 pp 107-109
    def recurrence_id_property
      @recurrence_id_property ||= []
    end

    # set the the RECURRENCE-ID property
    # property_value should be an instance of either RiCal::DateTimeValue or RiCall::DateValue may be passed to this method
    def recurrence_id_property=(property_values)
      recurrence_id_property = property_value
    end

    # return the value of the RECURRENCE-ID property
    # which will be an instance of either DateTime or Date
    def recurrence_id
      recurrence_id_property.value
    end

    # set the value of the RECURRENCE-ID property
    def recurrence_id=(*ruby_values)
      recurrence_id_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :recurrence_id_property

    def recurrence_id_property_from_string(line) # :nodoc:
      @recurrence_id_property = DateTimeValue.from_separated_line(line)
    end


    # return the the DTEND property
    # which will be an instances of either RiCal::DateTimeValue or RiCall::DateValue
    # see RFC 2445 4.8.2.2 pp 91-92
    def dtend_property
      @dtend_property ||= []
    end

    # set the the DTEND property
    # property_value should be an instance of either RiCal::DateTimeValue or RiCall::DateValue may be passed to this method
    def dtend_property=(property_values)
      dtend_property = property_value
    end

    # return the value of the DTEND property
    # which will be an instance of either DateTime or Date
    def dtend
      dtend_property.value
    end

    # set the value of the DTEND property
    def dtend=(*ruby_values)
      dtend_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :dtend_property

    def dtend_property_from_string(line) # :nodoc:
      @dtend_property = DateTimeValue.from_separated_line(line)
    end


    # return the the DURATION property
    # which will be an instances of RiCal::DurationValue
    # see RFC 2445 4.8.2.5 pp 94-95
    def duration_property
      @duration_property ||= []
    end

    # set the the DURATION property
    # property_value should be an instance of RiCal::DurationValue may be passed to this method
    def duration_property=(property_values)
      duration_property = property_value
    end

    # return the value of the DURATION property
    # which will be an instance of Duration
    def duration
      duration_property.value
    end

    # set the value of the DURATION property
    def duration=(*ruby_values)
      duration_property= DurationValue.convert(ruby_val)
    end

    attr_accessor :duration_property

    def duration_property_from_string(line) # :nodoc:
      @duration_property = DurationValue.new(line)
    end


    # return the the ATTACH property
    # which will be an array of instances of RiCal::TextValue
    def attach_property
      @attach_property ||= []
    end

    # set the the ATTACH property
    # one or more instances of RiCal::TextValue may be passed to this method
    def attach_property=(*property_values)
      attach_property= property_values
    end

    # return the value of the ATTACH property
    # which will be an array of instances of String
    def attach
      attach_property.map {|prop| prop.value}
    end

    # set the value of the ATTACH property
    # one or more instances of String may be passed to this method
    def attach=(*ruby_values)
      attach_property = ruby_values.map {|val| TextValue.convert(val)}
    end

    def attach_property_from_string(line) # :nodoc:
      attach_property << TextValue.new(line)
    end

    # return the the ATTENDEE property
    # which will be an array of instances of RiCal::CalAddressValue
    # see RFC 2445 4.8.4.1 pp 102-104
    def attendee_property
      @attendee_property ||= []
    end

    # set the the ATTENDEE property
    # one or more instances of RiCal::CalAddressValue may be passed to this method
    def attendee_property=(*property_values)
      attendee_property= property_values
    end

    # return the value of the ATTENDEE property
    # which will be an array of instances of CalAddress
    def attendee
      attendee_property.map {|prop| prop.value}
    end

    # set the value of the ATTENDEE property
    # one or more instances of CalAddress may be passed to this method
    def attendee=(*ruby_values)
      attendee_property = ruby_values.map {|val| CalAddressValue.convert(val)}
    end

    def attendee_property_from_string(line) # :nodoc:
      attendee_property << CalAddressValue.new(line)
    end

    # return the the CATEGORIES property
    # which will be an array of instances of RiCal::ArrayValue
    # see RFC 2445 4.8.1.4 pp 78-79
    def categories_property
      @categories_property ||= []
    end

    # set the the CATEGORIES property
    # one or more instances of RiCal::ArrayValue may be passed to this method
    def categories_property=(*property_values)
      categories_property= property_values
    end

    # return the value of the CATEGORIES property
    # which will be an array of instances of Array
    def categories
      categories_property.map {|prop| prop.value}
    end

    # set the value of the CATEGORIES property
    # one or more instances of Array may be passed to this method
    def categories=(*ruby_values)
      categories_property = ruby_values.map {|val| ArrayValue.convert(val)}
    end

    def categories_property_from_string(line) # :nodoc:
      categories_property << ArrayValue.new(line)
    end

    # return the the COMMENT property
    # which will be an array of instances of RiCal::TextValue
    # see RFC 2445 4.8.1.4 pp 80-81
    def comment_property
      @comment_property ||= []
    end

    # set the the COMMENT property
    # one or more instances of RiCal::TextValue may be passed to this method
    def comment_property=(*property_values)
      comment_property= property_values
    end

    # return the value of the COMMENT property
    # which will be an array of instances of String
    def comment
      comment_property.map {|prop| prop.value}
    end

    # set the value of the COMMENT property
    # one or more instances of String may be passed to this method
    def comment=(*ruby_values)
      comment_property = ruby_values.map {|val| TextValue.convert(val)}
    end

    def comment_property_from_string(line) # :nodoc:
      comment_property << TextValue.new(line)
    end

    # return the the CONTACT property
    # which will be an array of instances of RiCal::TextValue
    # see RFC 2445 4.8.4.2 pp 104-106
    def contact_property
      @contact_property ||= []
    end

    # set the the CONTACT property
    # one or more instances of RiCal::TextValue may be passed to this method
    def contact_property=(*property_values)
      contact_property= property_values
    end

    # return the value of the CONTACT property
    # which will be an array of instances of String
    def contact
      contact_property.map {|prop| prop.value}
    end

    # set the value of the CONTACT property
    # one or more instances of String may be passed to this method
    def contact=(*ruby_values)
      contact_property = ruby_values.map {|val| TextValue.convert(val)}
    end

    def contact_property_from_string(line) # :nodoc:
      contact_property << TextValue.new(line)
    end

    # return the the EXDATE property
    # which will be an array of instances of RiCal::DateListValue
    # see RFC 2445 4.8.5.1 pp 112-114
    def exdate_property
      @exdate_property ||= []
    end

    # set the the EXDATE property
    # one or more instances of RiCal::DateListValue may be passed to this method
    def exdate_property=(*property_values)
      exdate_property= property_values
    end

    # return the value of the EXDATE property
    # which will be an array of instances of DateList
    def exdate
      exdate_property.map {|prop| prop.value}
    end

    # set the value of the EXDATE property
    # one or more instances of DateList may be passed to this method
    def exdate=(*ruby_values)
      exdate_property = ruby_values.map {|val| DateListValue.convert(val)}
    end

    def exdate_property_from_string(line) # :nodoc:
      exdate_property << DateListValue.new(line)
    end

    # return the the RDATE property
    # which will be an array of instances of RiCal::DateListValue
    # see RFC 2445 4.8.5.3 pp 115-117
    def rdate_property
      @rdate_property ||= []
    end

    # set the the RDATE property
    # one or more instances of RiCal::DateListValue may be passed to this method
    def rdate_property=(*property_values)
      rdate_property= property_values
    end

    # return the value of the RDATE property
    # which will be an array of instances of DateList
    def rdate
      rdate_property.map {|prop| prop.value}
    end

    # set the value of the RDATE property
    # one or more instances of DateList may be passed to this method
    def rdate=(*ruby_values)
      rdate_property = ruby_values.map {|val| DateListValue.convert(val)}
    end

    def rdate_property_from_string(line) # :nodoc:
      rdate_property << DateListValue.new(line)
    end

    # return the the EXRULE property
    # which will be an array of instances of RiCal::RecurrenceRuleValue
    # see RFC 2445 4.8.5.2 pp 114-125
    def exrule_property
      @exrule_property ||= []
    end

    # set the the EXRULE property
    # one or more instances of RiCal::RecurrenceRuleValue may be passed to this method
    def exrule_property=(*property_values)
      exrule_property= property_values
    end

    # return the value of the EXRULE property
    # which will be an array of instances of RecurrenceRule
    def exrule
      exrule_property.map {|prop| prop.value}
    end

    # set the value of the EXRULE property
    # one or more instances of RecurrenceRule may be passed to this method
    def exrule=(*ruby_values)
      exrule_property = ruby_values.map {|val| RecurrenceRuleValue.convert(val)}
    end

    def exrule_property_from_string(line) # :nodoc:
      exrule_property << RecurrenceRuleValue.new(line)
    end

    # return the the REQUEST-STATUS property
    # which will be an array of instances of RiCal::TextValue
    # see RFC 2445 4.8.8.2 pp 134-136
    def request_status_property
      @request_status_property ||= []
    end

    # set the the REQUEST-STATUS property
    # one or more instances of RiCal::TextValue may be passed to this method
    def request_status_property=(*property_values)
      request_status_property= property_values
    end

    # return the value of the REQUEST-STATUS property
    # which will be an array of instances of String
    def request_status
      request_status_property.map {|prop| prop.value}
    end

    # set the value of the REQUEST-STATUS property
    # one or more instances of String may be passed to this method
    def request_status=(*ruby_values)
      request_status_property = ruby_values.map {|val| TextValue.convert(val)}
    end

    def request_status_property_from_string(line) # :nodoc:
      request_status_property << TextValue.new(line)
    end

    # return the the RELATED-TO property
    # which will be an array of instances of RiCal::TextValue
    # see RFC 2445 4.8.4.5 pp 109-110
    def related_to_property
      @related_to_property ||= []
    end

    # set the the RELATED-TO property
    # one or more instances of RiCal::TextValue may be passed to this method
    def related_to_property=(*property_values)
      related_to_property= property_values
    end

    # return the value of the RELATED-TO property
    # which will be an array of instances of String
    def related_to
      related_to_property.map {|prop| prop.value}
    end

    # set the value of the RELATED-TO property
    # one or more instances of String may be passed to this method
    def related_to=(*ruby_values)
      related_to_property = ruby_values.map {|val| TextValue.convert(val)}
    end

    def related_to_property_from_string(line) # :nodoc:
      related_to_property << TextValue.new(line)
    end

    # return the the RESOURCES property
    # which will be an array of instances of RiCal::ArrayValue
    # see RFC 2445 4.8.1.10 pp 87-88
    def resources_property
      @resources_property ||= []
    end

    # set the the RESOURCES property
    # one or more instances of RiCal::ArrayValue may be passed to this method
    def resources_property=(*property_values)
      resources_property= property_values
    end

    # return the value of the RESOURCES property
    # which will be an array of instances of Array
    def resources
      resources_property.map {|prop| prop.value}
    end

    # set the value of the RESOURCES property
    # one or more instances of Array may be passed to this method
    def resources=(*ruby_values)
      resources_property = ruby_values.map {|val| ArrayValue.convert(val)}
    end

    def resources_property_from_string(line) # :nodoc:
      resources_property << ArrayValue.new(line)
    end

    # return the the RRULE property
    # which will be an array of instances of RiCal::RecurrenceRuleValue
    # see RFC 2445 4.8.5.4 pp 117-117
    def rrule_property
      @rrule_property ||= []
    end

    # set the the RRULE property
    # one or more instances of RiCal::RecurrenceRuleValue may be passed to this method
    def rrule_property=(*property_values)
      rrule_property= property_values
    end

    # return the value of the RRULE property
    # which will be an array of instances of RecurrenceRule
    def rrule
      rrule_property.map {|prop| prop.value}
    end

    # set the value of the RRULE property
    # one or more instances of RecurrenceRule may be passed to this method
    def rrule=(*ruby_values)
      rrule_property = ruby_values.map {|val| RecurrenceRuleValue.convert(val)}
    end

    def rrule_property_from_string(line) # :nodoc:
      rrule_property << RecurrenceRuleValue.new(line)
    end

    def self.property_parser
      {"RELATED-TO"=>:related_to_property_from_string, "RDATE"=>:rdate_property_from_string, "DTEND"=>:dtend_property_from_string, "DTSTART"=>:dtstart_property_from_string, "TRANSP"=>:transp_property_from_string, "DTSTAMP"=>:dtstamp_property_from_string, "LOCATION"=>:location_property_from_string, "EXRULE"=>:exrule_property_from_string, "CONTACT"=>:contact_property_from_string, "URL"=>:url_property_from_string, "LAST-MODIFIED"=>:last_modified_property_from_string, "RESOURCES"=>:resources_property_from_string, "EXDATE"=>:exdate_property_from_string, "ATTACH"=>:attach_property_from_string, "UID"=>:uid_property_from_string, "SEQUENCE"=>:sequence_property_from_string, "CATEGORIES"=>:categories_property_from_string, "RECURRENCE-ID"=>:recurrence_id_property_from_string, "SUMMARY"=>:summary_property_from_string, "GEO"=>:geo_property_from_string, "CLASS"=>:class_property_from_string, "RRULE"=>:rrule_property_from_string, "STATUS"=>:status_property_from_string, "ATTENDEE"=>:attendee_property_from_string, "PRIORITY"=>:priority_property_from_string, "ORGANIZER"=>:organizer_property_from_string, "CREATED"=>:created_property_from_string, "REQUEST-STATUS"=>:request_status_property_from_string, "COMMENT"=>:comment_property_from_string, "DURATION"=>:duration_property_from_string, "DESCRIPTION"=>:description_property_from_string}
    end

    def mutual_exclusion_violation
      return true if [:dtend_property, :duration_property].inject(0) {|sum, prop| send(prop) ? sum + 1 : sum} > 1
      false
    end
    # END GENERATED ATTRIBUTE CODE

   end
end
