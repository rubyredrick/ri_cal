module RiCal
  class Vtodo < Ventity
    # BEGIN GENERATED ATTRIBUTE CODE

    # return the the CLASS property
    # which will be an instances of RiCal::TextValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines the access classification for a calendar component.
    # 
    # see RFC 2445 4.8.1.3 pp 79-80
    def class_property
      @class_property
    end

    # set the the CLASS property
    # property value should be an instance of RiCal::TextValue
    def class_property=(property_value)
      class_property = property_value
    end

    # set the value of the CLASS property
    def security_class=(ruby_value)
      class_property= TextValue.convert(ruby_value)
    end

    # return the value of the CLASS property
    # which will be an instance of String
    def security_class
      value_of_property(class_property)
    end

    def class_property_from_string(line) # :nodoc:
      @class_property = TextValue.new(line)
    end


    # return the the COMPLETED property
    # which will be an instances of RiCal::DateTimeValue
    # 
    # [purpose (from RFC 2445)]
    # This property specifies the date and time that a to-do was actually completed.
    # 
    # see RFC 2445 4.8.2.1 pp 90-91
    def completed_property
      @completed_property
    end

    # set the the COMPLETED property
    # property value should be an instance of RiCal::DateTimeValue
    def completed_property=(property_value)
      completed_property = property_value
    end

    # set the value of the COMPLETED property
    def completed=(ruby_value)
      completed_property= DateTimeValue.convert(ruby_value)
    end

    # return the value of the COMPLETED property
    # which will be an instance of DateTime
    def completed
      value_of_property(completed_property)
    end

    def completed_property_from_string(line) # :nodoc:
      @completed_property = DateTimeValue.new(line)
    end


    # return the the CREATED property
    # which will be an instances of RiCal::DateTimeValue
    # 
    # [purpose (from RFC 2445)]
    # This property specifies the date and time that the calendar information was created by teh calendar user agent in the calendar store.
    # 
    # see RFC 2445 4.8.7.1 pp 129-130
    def created_property
      @created_property
    end

    # set the the CREATED property
    # property value should be an instance of RiCal::DateTimeValue
    def created_property=(property_value)
      created_property = property_value
    end

    # set the value of the CREATED property
    def created=(ruby_value)
      created_property= DateTimeValue.convert(ruby_value)
    end

    # return the value of the CREATED property
    # which will be an instance of DateTime
    def created
      value_of_property(created_property)
    end

    def created_property_from_string(line) # :nodoc:
      @created_property = DateTimeValue.new(line)
    end


    # return the the DESCRIPTION property
    # which will be an instances of RiCal::TextValue
    # 
    # [purpose (from RFC 2445)]
    # This property provides a more complete description of the calendar component, than that provided by the "SUMMARY" property.
    # 
    # see RFC 2445 4.8.1.5 pp 81-82
    def description_property
      @description_property
    end

    # set the the DESCRIPTION property
    # property value should be an instance of RiCal::TextValue
    def description_property=(property_value)
      description_property = property_value
    end

    # set the value of the DESCRIPTION property
    def description=(ruby_value)
      description_property= TextValue.convert(ruby_value)
    end

    # return the value of the DESCRIPTION property
    # which will be an instance of String
    def description
      value_of_property(description_property)
    end

    def description_property_from_string(line) # :nodoc:
      @description_property = TextValue.new(line)
    end


    # return the the DTSTAMP property
    # which will be an instances of RiCal::DateTimeValue
    # 
    # [purpose (from RFC 2445)]
    # This property indicates the date/time that the instance of the iCalendar object was created.
    # 
    # see RFC 2445 4.8.7.2 pp 130-131
    def dtstamp_property
      @dtstamp_property
    end

    # set the the DTSTAMP property
    # property value should be an instance of RiCal::DateTimeValue
    def dtstamp_property=(property_value)
      dtstamp_property = property_value
    end

    # set the value of the DTSTAMP property
    def dtstamp=(ruby_value)
      dtstamp_property= DateTimeValue.convert(ruby_value)
    end

    # return the value of the DTSTAMP property
    # which will be an instance of DateTime
    def dtstamp
      value_of_property(dtstamp_property)
    end

    def dtstamp_property_from_string(line) # :nodoc:
      @dtstamp_property = DateTimeValue.new(line)
    end


    # return the the DTSTART property
    # which will be an instances of either RiCal::DateTimeValue or RiCall::DateValue
    # 
    # [purpose (from RFC 2445)]
    # This property specifies when the calendar component begins.
    # 
    # see RFC 2445 4.8.2.4 pp 93-94
    def dtstart_property
      @dtstart_property
    end

    # set the the DTSTART property
    # property value should be an instance of either RiCal::DateTimeValue or RiCall::DateValue
    def dtstart_property=(property_value)
      dtstart_property = property_value
    end

    # set the value of the DTSTART property
    def dtstart=(ruby_value)
      dtstart_property= DateTimeValue.convert(ruby_value)
    end

    # return the value of the DTSTART property
    # which will be an instance of either DateTime or Date
    def dtstart
      value_of_property(dtstart_property)
    end

    def dtstart_property_from_string(line) # :nodoc:
      @dtstart_property = DateTimeValue.from_separated_line(line)
    end


    # return the the GEO property
    # which will be an instances of RiCal::GeoValue
    # 
    # [purpose (from RFC 2445)]
    # This property specifies information related to the global position for the activity specified by a calendar component.
    # 
    # see RFC 2445 4.8.1.6 pp 82-83
    def geo_property
      @geo_property
    end

    # set the the GEO property
    # property value should be an instance of RiCal::GeoValue
    def geo_property=(property_value)
      geo_property = property_value
    end

    # set the value of the GEO property
    def geo=(ruby_value)
      geo_property= GeoValue.convert(ruby_value)
    end

    # return the value of the GEO property
    # which will be an instance of Geo
    def geo
      value_of_property(geo_property)
    end

    def geo_property_from_string(line) # :nodoc:
      @geo_property = GeoValue.new(line)
    end


    # return the the LAST-MODIFIED property
    # which will be an instances of RiCal::DateTimeValue
    # 
    # [purpose (from RFC 2445)]
    # This property specifies the date and time that the information associated with the calendar component was last revised in teh calendar store.
    # 
    # see RFC 2445 4.8.7.3 p 131
    def last_modified_property
      @last_modified_property
    end

    # set the the LAST-MODIFIED property
    # property value should be an instance of RiCal::DateTimeValue
    def last_modified_property=(property_value)
      last_modified_property = property_value
    end

    # set the value of the LAST-MODIFIED property
    def last_modified=(ruby_value)
      last_modified_property= DateTimeValue.convert(ruby_value)
    end

    # return the value of the LAST-MODIFIED property
    # which will be an instance of DateTime
    def last_modified
      value_of_property(last_modified_property)
    end

    def last_modified_property_from_string(line) # :nodoc:
      @last_modified_property = DateTimeValue.new(line)
    end


    # return the the LOCATION property
    # which will be an instances of RiCal::TextValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines the intended venue for the activity defined by a calendar component.
    # 
    # see RFC 2445 4.8.1.7 pp 84
    def location_property
      @location_property
    end

    # set the the LOCATION property
    # property value should be an instance of RiCal::TextValue
    def location_property=(property_value)
      location_property = property_value
    end

    # set the value of the LOCATION property
    def location=(ruby_value)
      location_property= TextValue.convert(ruby_value)
    end

    # return the value of the LOCATION property
    # which will be an instance of String
    def location
      value_of_property(location_property)
    end

    def location_property_from_string(line) # :nodoc:
      @location_property = TextValue.new(line)
    end


    # return the the ORGANIZER property
    # which will be an instances of RiCal::CalAddressValue
    # 
    # [purpose (from RFC 2445)]
    # The property defines the organizer for a calendar component.
    # 
    # see RFC 2445 4.8.4.3 pp 106-107
    def organizer_property
      @organizer_property
    end

    # set the the ORGANIZER property
    # property value should be an instance of RiCal::CalAddressValue
    def organizer_property=(property_value)
      organizer_property = property_value
    end

    # set the value of the ORGANIZER property
    def organizer=(ruby_value)
      organizer_property= CalAddressValue.convert(ruby_value)
    end

    # return the value of the ORGANIZER property
    # which will be an instance of CalAddress
    def organizer
      value_of_property(organizer_property)
    end

    def organizer_property_from_string(line) # :nodoc:
      @organizer_property = CalAddressValue.new(line)
    end


    # return the the PERCENT-COMPLETE property
    # which will be an instances of RiCal::IntegerValue
    # 
    # [purpose (from RFC 2445)]
    # This property is used by an assignee or delegatee of a to-do to convey the percent completion of a to-do to the Organizer.
    # 
    # see RFC 2445 4.8.1.8 pp 85
    def percent_complete_property
      @percent_complete_property
    end

    # set the the PERCENT-COMPLETE property
    # property value should be an instance of RiCal::IntegerValue
    def percent_complete_property=(property_value)
      percent_complete_property = property_value
    end

    # set the value of the PERCENT-COMPLETE property
    def percent_complete=(ruby_value)
      percent_complete_property= IntegerValue.convert(ruby_value)
    end

    # return the value of the PERCENT-COMPLETE property
    # which will be an instance of Integer
    def percent_complete
      value_of_property(percent_complete_property)
    end

    def percent_complete_property_from_string(line) # :nodoc:
      @percent_complete_property = IntegerValue.new(line)
    end


    # return the the PRIORITY property
    # which will be an instances of RiCal::IntegerValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines the relative priority for a calendar component.
    # 
    # see RFC 2445 4.8.1.9 pp 85-87
    def priority_property
      @priority_property
    end

    # set the the PRIORITY property
    # property value should be an instance of RiCal::IntegerValue
    def priority_property=(property_value)
      priority_property = property_value
    end

    # set the value of the PRIORITY property
    def priority=(ruby_value)
      priority_property= IntegerValue.convert(ruby_value)
    end

    # return the value of the PRIORITY property
    # which will be an instance of Integer
    def priority
      value_of_property(priority_property)
    end

    def priority_property_from_string(line) # :nodoc:
      @priority_property = IntegerValue.new(line)
    end


    # return the the RECURRENCE-ID property
    # which will be an instances of either RiCal::DateTimeValue or RiCall::DateValue
    # 
    # [purpose (from RFC 2445)]
    # This property is used in conjunction with the "UID" and "SEQUENCE" property to identify a specific instance of a recurring "VEVENT", "VTODO" or "VJOURNAL" calendar component. The property value is the effective value of the "DTSTART" property of the recurrence instance.
    # 
    # see RFC 2445 4.8.4.4 pp 107-109
    def recurrence_id_property
      @recurrence_id_property
    end

    # set the the RECURRENCE-ID property
    # property value should be an instance of either RiCal::DateTimeValue or RiCall::DateValue
    def recurrence_id_property=(property_value)
      recurrence_id_property = property_value
    end

    # set the value of the RECURRENCE-ID property
    def recurrence_id=(ruby_value)
      recurrence_id_property= DateTimeValue.convert(ruby_value)
    end

    # return the value of the RECURRENCE-ID property
    # which will be an instance of either DateTime or Date
    def recurrence_id
      value_of_property(recurrence_id_property)
    end

    def recurrence_id_property_from_string(line) # :nodoc:
      @recurrence_id_property = DateTimeValue.from_separated_line(line)
    end


    # return the the SEQUENCE property
    # which will be an instances of RiCal::IntegerValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines the revision sequence number of the calendar component within a sequence of revisions.
    # 
    # see RFC 2445 4.8.7.4 pp 131-133
    def sequence_property
      @sequence_property
    end

    # set the the SEQUENCE property
    # property value should be an instance of RiCal::IntegerValue
    def sequence_property=(property_value)
      sequence_property = property_value
    end

    # set the value of the SEQUENCE property
    def sequence=(ruby_value)
      sequence_property= IntegerValue.convert(ruby_value)
    end

    # return the value of the SEQUENCE property
    # which will be an instance of Integer
    def sequence
      value_of_property(sequence_property)
    end

    def sequence_property_from_string(line) # :nodoc:
      @sequence_property = IntegerValue.new(line)
    end


    # return the the STATUS property
    # which will be an instances of RiCal::TextValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines a short summary or subject for the calendar component.
    # 
    # see RFC 2445 4.8.1.11 pp 80-89
    def status_property
      @status_property
    end

    # set the the STATUS property
    # property value should be an instance of RiCal::TextValue
    def status_property=(property_value)
      status_property = property_value
    end

    # set the value of the STATUS property
    def status=(ruby_value)
      status_property= TextValue.convert(ruby_value)
    end

    # return the value of the STATUS property
    # which will be an instance of String
    def status
      value_of_property(status_property)
    end

    def status_property_from_string(line) # :nodoc:
      @status_property = TextValue.new(line)
    end


    # return the the SUMMARY property
    # which will be an instances of RiCal::TextValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines a short summary or subject for the calendar component.
    # 
    # see RFC 2445 4.8.1.12 pp 89-90
    def summary_property
      @summary_property
    end

    # set the the SUMMARY property
    # property value should be an instance of RiCal::TextValue
    def summary_property=(property_value)
      summary_property = property_value
    end

    # set the value of the SUMMARY property
    def summary=(ruby_value)
      summary_property= TextValue.convert(ruby_value)
    end

    # return the value of the SUMMARY property
    # which will be an instance of String
    def summary
      value_of_property(summary_property)
    end

    def summary_property_from_string(line) # :nodoc:
      @summary_property = TextValue.new(line)
    end


    # return the the UID property
    # which will be an instances of RiCal::TextValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines the persistent, globally unique identifier for the calendar component.
    # 
    # see RFC 2445 4.8.4.7 pp 111-112
    def uid_property
      @uid_property
    end

    # set the the UID property
    # property value should be an instance of RiCal::TextValue
    def uid_property=(property_value)
      uid_property = property_value
    end

    # set the value of the UID property
    def uid=(ruby_value)
      uid_property= TextValue.convert(ruby_value)
    end

    # return the value of the UID property
    # which will be an instance of String
    def uid
      value_of_property(uid_property)
    end

    def uid_property_from_string(line) # :nodoc:
      @uid_property = TextValue.new(line)
    end


    # return the the URL property
    # which will be an instances of RiCal::UriValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines a Uniform Resource Locator (URL) associated with the iCalendar object.
    # 
    # see RFC 2445 4.8.4.6 pp 110-111
    def url_property
      @url_property
    end

    # set the the URL property
    # property value should be an instance of RiCal::UriValue
    def url_property=(property_value)
      url_property = property_value
    end

    # set the value of the URL property
    def url=(ruby_value)
      url_property= UriValue.convert(ruby_value)
    end

    # return the value of the URL property
    # which will be an instance of Uri
    def url
      value_of_property(url_property)
    end

    def url_property_from_string(line) # :nodoc:
      @url_property = UriValue.new(line)
    end


    # return the the DUE property
    # which will be an instances of either RiCal::DateTimeValue or RiCall::DateValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines the date and time that a to-do is expected to be completed.
    # 
    # see RFC 2445 4.8.2.3 pp 92-93
    def due_property
      @due_property
    end

    # set the the DUE property
    # property value should be an instance of either RiCal::DateTimeValue or RiCall::DateValue
    def due_property=(property_value)
      due_property = property_value
    end

    # set the value of the DUE property
    def due=(ruby_value)
      due_property= DateTimeValue.convert(ruby_value)
    end

    # return the value of the DUE property
    # which will be an instance of either DateTime or Date
    def due
      value_of_property(due_property)
    end

    def due_property_from_string(line) # :nodoc:
      @due_property = DateTimeValue.from_separated_line(line)
    end


    # return the the DURATION property
    # which will be an instances of RiCal::DurationValue
    # 
    # [purpose (from RFC 2445)]
    # This property specifies a positive duration of time.
    # 
    # see RFC 2445 4.8.2.5 pp 94-95
    def duration_property
      @duration_property
    end

    # set the the DURATION property
    # property value should be an instance of RiCal::DurationValue
    def duration_property=(property_value)
      duration_property = property_value
    end

    # set the value of the DURATION property
    def duration=(ruby_value)
      duration_property= DurationValue.convert(ruby_value)
    end

    # return the value of the DURATION property
    # which will be an instance of Duration
    def duration
      value_of_property(duration_property)
    end

    def duration_property_from_string(line) # :nodoc:
      @duration_property = DurationValue.new(line)
    end


    # return the the ATTACH property
    # which will be an array of instances of RiCal::UriValue
    # 
    # [purpose (from RFC 2445)]
    # The property provides the capability to associate a document object with a calendar component.
    # 
    # see RFC 2445 4.8.1.1 pp 77-78
    def attach_property
      @attach_property ||= []
    end

    # set the the ATTACH property
    # one or more instances of RiCal::UriValue may be passed to this method
    def attach_property=(*property_values)
      attach_property= property_values
    end

    # set the value of the ATTACH property
    # one or more instances of Uri may be passed to this method
    def attach=(*ruby_values)
      attach_property = ruby_values.map {|val| UriValue.convert(val)}
    end

    # return the value of the ATTACH property
    # which will be an array of instances of Uri
    def attach
      attach_property.map {|prop| value_of_property(prop)}
    end

    def attach_property_from_string(line) # :nodoc:
      attach_property << UriValue.new(line)
    end

    # return the the ATTENDEE property
    # which will be an array of instances of RiCal::CalAddressValue
    # 
    # [purpose (from RFC 2445)]
    # The property defines an 'Attendee' within a calendar component.
    # 
    # see RFC 2445 4.8.4.1 pp 102-104
    def attendee_property
      @attendee_property ||= []
    end

    # set the the ATTENDEE property
    # one or more instances of RiCal::CalAddressValue may be passed to this method
    def attendee_property=(*property_values)
      attendee_property= property_values
    end

    # set the value of the ATTENDEE property
    # one or more instances of CalAddress may be passed to this method
    def attendee=(*ruby_values)
      attendee_property = ruby_values.map {|val| CalAddressValue.convert(val)}
    end

    # return the value of the ATTENDEE property
    # which will be an array of instances of CalAddress
    def attendee
      attendee_property.map {|prop| value_of_property(prop)}
    end

    def attendee_property_from_string(line) # :nodoc:
      attendee_property << CalAddressValue.new(line)
    end

    # return the the CATEGORIES property
    # which will be an array of instances of RiCal::ArrayValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines the categories for a calendar component.
    # 
    # see RFC 2445 4.8.1.2 pp 78-79
    def categories_property
      @categories_property ||= []
    end

    # set the the CATEGORIES property
    # one or more instances of RiCal::ArrayValue may be passed to this method
    def categories_property=(*property_values)
      categories_property= property_values
    end

    # set the value of the CATEGORIES property
    # one or more instances of Array may be passed to this method
    def categories=(*ruby_values)
      categories_property = ruby_values.map {|val| ArrayValue.convert(val)}
    end

    # return the value of the CATEGORIES property
    # which will be an array of instances of Array
    def categories
      categories_property.map {|prop| value_of_property(prop)}
    end

    def categories_property_from_string(line) # :nodoc:
      categories_property << ArrayValue.new(line)
    end

    # return the the COMMENT property
    # which will be an array of instances of RiCal::TextValue
    # 
    # [purpose (from RFC 2445)]
    # This property specifies non-processing information intended to provide a comment to the calendar user.
    # 
    # see RFC 2445 4.8.1.4 pp 80-81
    def comment_property
      @comment_property ||= []
    end

    # set the the COMMENT property
    # one or more instances of RiCal::TextValue may be passed to this method
    def comment_property=(*property_values)
      comment_property= property_values
    end

    # set the value of the COMMENT property
    # one or more instances of String may be passed to this method
    def comment=(*ruby_values)
      comment_property = ruby_values.map {|val| TextValue.convert(val)}
    end

    # return the value of the COMMENT property
    # which will be an array of instances of String
    def comment
      comment_property.map {|prop| value_of_property(prop)}
    end

    def comment_property_from_string(line) # :nodoc:
      comment_property << TextValue.new(line)
    end

    # return the the CONTACT property
    # which will be an array of instances of RiCal::TextValue
    # 
    # [purpose (from RFC 2445)]
    # The property is used to represent contact information oralternately a reference to contact information associated with the calendar component.
    # 
    # see RFC 2445 4.8.4.2 pp 104-106
    def contact_property
      @contact_property ||= []
    end

    # set the the CONTACT property
    # one or more instances of RiCal::TextValue may be passed to this method
    def contact_property=(*property_values)
      contact_property= property_values
    end

    # set the value of the CONTACT property
    # one or more instances of String may be passed to this method
    def contact=(*ruby_values)
      contact_property = ruby_values.map {|val| TextValue.convert(val)}
    end

    # return the value of the CONTACT property
    # which will be an array of instances of String
    def contact
      contact_property.map {|prop| value_of_property(prop)}
    end

    def contact_property_from_string(line) # :nodoc:
      contact_property << TextValue.new(line)
    end

    # return the the EXDATE property
    # which will be an array of instances of RiCal::DateListValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines the list of date/time exceptions for a recurring calendar component.
    # 
    # see RFC 2445 4.8.5.1 pp 112-114
    def exdate_property
      @exdate_property ||= []
    end

    # set the the EXDATE property
    # one or more instances of RiCal::DateListValue may be passed to this method
    def exdate_property=(*property_values)
      exdate_property= property_values
    end

    # set the value of the EXDATE property
    # one or more instances of DateList may be passed to this method
    def exdate=(*ruby_values)
      exdate_property = ruby_values.map {|val| DateListValue.convert(val)}
    end

    # return the value of the EXDATE property
    # which will be an array of instances of DateList
    def exdate
      exdate_property.map {|prop| value_of_property(prop)}
    end

    def exdate_property_from_string(line) # :nodoc:
      exdate_property << DateListValue.new(line)
    end

    # return the the EXRULE property
    # which will be an array of instances of RiCal::RecurrenceRuleValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines a rule or repeating pattern for an exception to a recurrence set.
    # 
    # see RFC 2445 4.8.5.2 pp 114-125
    def exrule_property
      @exrule_property ||= []
    end

    # set the the EXRULE property
    # one or more instances of RiCal::RecurrenceRuleValue may be passed to this method
    def exrule_property=(*property_values)
      exrule_property= property_values
    end

    # set the value of the EXRULE property
    # one or more instances of RecurrenceRule may be passed to this method
    def exrule=(*ruby_values)
      exrule_property = ruby_values.map {|val| RecurrenceRuleValue.convert(val)}
    end

    # return the value of the EXRULE property
    # which will be an array of instances of RecurrenceRule
    def exrule
      exrule_property.map {|prop| value_of_property(prop)}
    end

    def exrule_property_from_string(line) # :nodoc:
      exrule_property << RecurrenceRuleValue.new(line)
    end

    # return the the REQUEST-STATUS property
    # which will be an array of instances of RiCal::TextValue
    # 
    # see RFC 2445 4.8.8.2 pp 134-136
    def request_status_property
      @request_status_property ||= []
    end

    # set the the REQUEST-STATUS property
    # one or more instances of RiCal::TextValue may be passed to this method
    def request_status_property=(*property_values)
      request_status_property= property_values
    end

    # set the value of the REQUEST-STATUS property
    # one or more instances of String may be passed to this method
    def request_status=(*ruby_values)
      request_status_property = ruby_values.map {|val| TextValue.convert(val)}
    end

    # return the value of the REQUEST-STATUS property
    # which will be an array of instances of String
    def request_status
      request_status_property.map {|prop| value_of_property(prop)}
    end

    def request_status_property_from_string(line) # :nodoc:
      request_status_property << TextValue.new(line)
    end

    # return the the RELATED-TO property
    # which will be an array of instances of RiCal::TextValue
    # 
    # [purpose (from RFC 2445)]
    # The property is used to represent a relationship or reference between one calendar component and another.
    # 
    # see RFC 2445 4.8.4.5 pp 109-110
    def related_to_property
      @related_to_property ||= []
    end

    # set the the RELATED-TO property
    # one or more instances of RiCal::TextValue may be passed to this method
    def related_to_property=(*property_values)
      related_to_property= property_values
    end

    # set the value of the RELATED-TO property
    # one or more instances of String may be passed to this method
    def related_to=(*ruby_values)
      related_to_property = ruby_values.map {|val| TextValue.convert(val)}
    end

    # return the value of the RELATED-TO property
    # which will be an array of instances of String
    def related_to
      related_to_property.map {|prop| value_of_property(prop)}
    end

    def related_to_property_from_string(line) # :nodoc:
      related_to_property << TextValue.new(line)
    end

    # return the the RESOURCES property
    # which will be an array of instances of RiCal::ArrayValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines the equipment or resources anticipated for an activity specified by a calendar entity.
    # 
    # see RFC 2445 4.8.1.10 pp 87-88
    def resources_property
      @resources_property ||= []
    end

    # set the the RESOURCES property
    # one or more instances of RiCal::ArrayValue may be passed to this method
    def resources_property=(*property_values)
      resources_property= property_values
    end

    # set the value of the RESOURCES property
    # one or more instances of Array may be passed to this method
    def resources=(*ruby_values)
      resources_property = ruby_values.map {|val| ArrayValue.convert(val)}
    end

    # return the value of the RESOURCES property
    # which will be an array of instances of Array
    def resources
      resources_property.map {|prop| value_of_property(prop)}
    end

    def resources_property_from_string(line) # :nodoc:
      resources_property << ArrayValue.new(line)
    end

    # return the the RDATE property
    # which will be an array of instances of RiCal::DateListValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines the list of date/times for a recurring calendar component.
    # 
    # see RFC 2445 4.8.5.3 pp 115-117
    def rdate_property
      @rdate_property ||= []
    end

    # set the the RDATE property
    # one or more instances of RiCal::DateListValue may be passed to this method
    def rdate_property=(*property_values)
      rdate_property= property_values
    end

    # set the value of the RDATE property
    # one or more instances of DateList may be passed to this method
    def rdate=(*ruby_values)
      rdate_property = ruby_values.map {|val| DateListValue.convert(val)}
    end

    # return the value of the RDATE property
    # which will be an array of instances of DateList
    def rdate
      rdate_property.map {|prop| value_of_property(prop)}
    end

    def rdate_property_from_string(line) # :nodoc:
      rdate_property << DateListValue.new(line)
    end

    # return the the RRULE property
    # which will be an array of instances of RiCal::RecurrenceRuleValue
    # 
    # [purpose (from RFC 2445)]
    # This property defines a rule or repeating pattern for recurring events, to-dos, or time zone definitions.
    # 
    # see RFC 2445 4.8.5.4 pp 117-125
    def rrule_property
      @rrule_property ||= []
    end

    # set the the RRULE property
    # one or more instances of RiCal::RecurrenceRuleValue may be passed to this method
    def rrule_property=(*property_values)
      rrule_property= property_values
    end

    # set the value of the RRULE property
    # one or more instances of RecurrenceRule may be passed to this method
    def rrule=(*ruby_values)
      rrule_property = ruby_values.map {|val| RecurrenceRuleValue.convert(val)}
    end

    # return the value of the RRULE property
    # which will be an array of instances of RecurrenceRule
    def rrule
      rrule_property.map {|prop| value_of_property(prop)}
    end

    def rrule_property_from_string(line) # :nodoc:
      rrule_property << RecurrenceRuleValue.new(line)
    end

    def self.property_parser
      {"RDATE"=>:rdate_property_from_string, "RELATED-TO"=>:related_to_property_from_string, "DTSTART"=>:dtstart_property_from_string, "DTSTAMP"=>:dtstamp_property_from_string, "LOCATION"=>:location_property_from_string, "EXRULE"=>:exrule_property_from_string, "CONTACT"=>:contact_property_from_string, "URL"=>:url_property_from_string, "LAST-MODIFIED"=>:last_modified_property_from_string, "COMPLETED"=>:completed_property_from_string, "RESOURCES"=>:resources_property_from_string, "EXDATE"=>:exdate_property_from_string, "ATTACH"=>:attach_property_from_string, "UID"=>:uid_property_from_string, "SEQUENCE"=>:sequence_property_from_string, "PERCENT-COMPLETE"=>:percent_complete_property_from_string, "CATEGORIES"=>:categories_property_from_string, "SUMMARY"=>:summary_property_from_string, "RECURRENCE-ID"=>:recurrence_id_property_from_string, "GEO"=>:geo_property_from_string, "CLASS"=>:class_property_from_string, "RRULE"=>:rrule_property_from_string, "STATUS"=>:status_property_from_string, "ATTENDEE"=>:attendee_property_from_string, "PRIORITY"=>:priority_property_from_string, "ORGANIZER"=>:organizer_property_from_string, "CREATED"=>:created_property_from_string, "REQUEST-STATUS"=>:request_status_property_from_string, "COMMENT"=>:comment_property_from_string, "DURATION"=>:duration_property_from_string, "DUE"=>:due_property_from_string, "DESCRIPTION"=>:description_property_from_string}
    end

    def mutual_exclusion_violation
      return true if [:due_property, :duration_property].inject(0) {|sum, prop| send(prop) ? sum + 1 : sum} > 1
      false
    end
    # END GENERATED ATTRIBUTE CODE
  end
end
