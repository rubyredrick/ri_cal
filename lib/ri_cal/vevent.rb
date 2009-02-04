module RiCal
  # 
  class Vevent < Ventity
    # BEGIN GENERATED ATTRIBUTE CODE

    # return the value of the CLASS property
    # which will be an instance of String
    # see RFC 2445 4.8.1.3 pp 79-80
    def security_class
      security_class_property.value
    end

    # set the CLASS property
    def security_class=(*ruby_values)
      security_class_property= TextValue.convert(ruby_val)
    end

    attr_accessor :security_class_property

    def security_class_property_from_string(line) # :nodoc:
      @security_class_property = TextValue.new(line)
    end


    # return the value of the CREATED property
    # which will be an instance of DateTime
    # see RFC 2445 4.8.7.1 pp 129-130
    def created
      created_property.value
    end

    # set the CREATED property
    def created=(*ruby_values)
      created_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :created_property

    def created_property_from_string(line) # :nodoc:
      @created_property = DateTimeValue.new(line)
    end


    # return the value of the DESCRIPTION property
    # which will be an instance of String
    # see RFC 2445 4.8.1.5 pp 81-82
    def description
      description_property.value
    end

    # set the DESCRIPTION property
    def description=(*ruby_values)
      description_property= TextValue.convert(ruby_val)
    end

    attr_accessor :description_property

    def description_property_from_string(line) # :nodoc:
      @description_property = TextValue.new(line)
    end


    # return the value of the DTSTART property
    # which will be an instance of either DateTime or Date
    # see RFC 2445 4.8.2.4 pp 93-94
    def dtstart
      dtstart_property.value
    end

    # set the DTSTART property
    def dtstart=(*ruby_values)
      dtstart_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :dtstart_property

    def dtstart_property_from_string(line) # :nodoc:
      @dtstart_property = DateTimeValue.from_separated_line(line)
    end


    # return the value of the GEO property
    # which will be an instance of String
    # see RFC 2445 4.8.1.6 pp 82-83
    def geo
      geo_property.value
    end

    # set the GEO property
    def geo=(*ruby_values)
      geo_property= TextValue.convert(ruby_val)
    end

    attr_accessor :geo_property

    def geo_property_from_string(line) # :nodoc:
      @geo_property = TextValue.new(line)
    end


    # return the value of the LAST-MODIFIED property
    # which will be an instance of DateTime
    # see RFC 2445 4.8.7.3 p 131
    def last_modified
      last_modified_property.value
    end

    # set the LAST-MODIFIED property
    def last_modified=(*ruby_values)
      last_modified_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :last_modified_property

    def last_modified_property_from_string(line) # :nodoc:
      @last_modified_property = DateTimeValue.new(line)
    end


    # return the value of the LOCATION property
    # which will be an instance of String
    # see RFC 2445 4.8.1.7 pp 84
    def location
      location_property.value
    end

    # set the LOCATION property
    def location=(*ruby_values)
      location_property= TextValue.convert(ruby_val)
    end

    attr_accessor :location_property

    def location_property_from_string(line) # :nodoc:
      @location_property = TextValue.new(line)
    end


    # return the value of the ORGANIZER property
    # which will be an instance of CalAddress
    # see RFC 2445 4.8.4.3 pp 106-107
    def organizer
      organizer_property.value
    end

    # set the ORGANIZER property
    def organizer=(*ruby_values)
      organizer_property= CalAddressValue.convert(ruby_val)
    end

    attr_accessor :organizer_property

    def organizer_property_from_string(line) # :nodoc:
      @organizer_property = CalAddressValue.new(line)
    end


    # return the value of the PRIORITY property
    # which will be an instance of Integer
    # see RFC 2445 4.8.1.9 pp 85-87
    def priority
      priority_property.value
    end

    # set the PRIORITY property
    def priority=(*ruby_values)
      priority_property= IntegerValue.convert(ruby_val)
    end

    attr_accessor :priority_property

    def priority_property_from_string(line) # :nodoc:
      @priority_property = IntegerValue.new(line)
    end


    # return the value of the DTSTAMP property
    # which will be an instance of DateTime
    # see RFC 2445 4.8.7.2 pp 130-131
    def dtstamp
      dtstamp_property.value
    end

    # set the DTSTAMP property
    def dtstamp=(*ruby_values)
      dtstamp_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :dtstamp_property

    def dtstamp_property_from_string(line) # :nodoc:
      @dtstamp_property = DateTimeValue.new(line)
    end


    # return the value of the SEQUENCE property
    # which will be an instance of Integer
    # see RFC 2445 4.8.7.4 pp 131-133
    def sequence
      sequence_property.value
    end

    # set the SEQUENCE property
    def sequence=(*ruby_values)
      sequence_property= IntegerValue.convert(ruby_val)
    end

    attr_accessor :sequence_property

    def sequence_property_from_string(line) # :nodoc:
      @sequence_property = IntegerValue.new(line)
    end


    # return the value of the STATUS property
    # which will be an instance of String
    # see RFC 2445 4.8.1.11 pp 80-89
    def status
      status_property.value
    end

    # set the STATUS property
    def status=(*ruby_values)
      status_property= TextValue.convert(ruby_val)
    end

    attr_accessor :status_property

    def status_property_from_string(line) # :nodoc:
      @status_property = TextValue.new(line)
    end


    # return the value of the SUMMARY property
    # which will be an instance of String
    # see RFC 2445 4.8.1.12 pp 89-90
    def summary
      summary_property.value
    end

    # set the SUMMARY property
    def summary=(*ruby_values)
      summary_property= TextValue.convert(ruby_val)
    end

    attr_accessor :summary_property

    def summary_property_from_string(line) # :nodoc:
      @summary_property = TextValue.new(line)
    end


    # return the value of the TRANSP property
    # which will be an instance of String
    # see RFC 2445 4.8.2.7 pp 96-97
    def transp
      transp_property.value
    end

    # set the TRANSP property
    def transp=(*ruby_values)
      transp_property= TextValue.convert(ruby_val)
    end

    attr_accessor :transp_property

    def transp_property_from_string(line) # :nodoc:
      @transp_property = TextValue.new(line)
    end


    # return the value of the UID property
    # which will be an instance of String
    # see RFC 2445 4.8.4.7 pp 111-112
    def uid
      uid_property.value
    end

    # set the UID property
    def uid=(*ruby_values)
      uid_property= TextValue.convert(ruby_val)
    end

    attr_accessor :uid_property

    def uid_property_from_string(line) # :nodoc:
      @uid_property = TextValue.new(line)
    end


    # return the value of the URL property
    # which will be an instance of Uri
    # see RFC 2445 4.8.4.6 pp 110-111
    def url
      url_property.value
    end

    # set the URL property
    def url=(*ruby_values)
      url_property= UriValue.convert(ruby_val)
    end

    attr_accessor :url_property

    def url_property_from_string(line) # :nodoc:
      @url_property = UriValue.new(line)
    end


    # return the value of the RECURRENCE-ID property
    # which will be an instance of either DateTime or Date
    # see RFC 2445 4.8.4.4 pp 107-109
    def recurrence_id
      recurrence_id_property.value
    end

    # set the RECURRENCE-ID property
    def recurrence_id=(*ruby_values)
      recurrence_id_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :recurrence_id_property

    def recurrence_id_property_from_string(line) # :nodoc:
      @recurrence_id_property = DateTimeValue.from_separated_line(line)
    end


    # return the value of the DTEND property
    # which will be an instance of either DateTime or Date
    # see RFC 2445 4.8.2.2 pp 91-92
    def dtend
      dtend_property.value
    end

    # set the DTEND property
    def dtend=(*ruby_values)
      dtend_property= DateTimeValue.convert(ruby_val)
    end

    attr_accessor :dtend_property

    def dtend_property_from_string(line) # :nodoc:
      @dtend_property = DateTimeValue.from_separated_line(line)
    end


    # return the value of the DURATION property
    # which will be an instance of Duration
    # see RFC 2445 4.8.2.5 pp 94-95
    def duration
      duration_property.value
    end

    # set the DURATION property
    def duration=(*ruby_values)
      duration_property= DurationValue.convert(ruby_val)
    end

    attr_accessor :duration_property

    def duration_property_from_string(line) # :nodoc:
      @duration_property = DurationValue.new(line)
    end


    # return the value of the ATTACH property
    # which will be an array of instances of String
    def attach
      attach_property.map {|prop| prop.value}
    end

    # set the ATTACH property
    # one or more instances of String may be passed to this method
    def attach=(*ruby_values)
      attach_property= ruby_values.map {|val| TextValue.convert(val)}
    end

    def attach_property # :nodoc:
      @attach_property ||= []
    end

    def attach_property_from_string(line) # :nodoc:
      attach_property << TextValue.new(line)
    end

    # return the value of the ATTENDEE property
    # which will be an array of instances of CalAddress
    # see RFC 2445 4.8.4.1 pp 102-104
    def attendee
      attendee_property.map {|prop| prop.value}
    end

    # set the ATTENDEE property
    # one or more instances of CalAddress may be passed to this method
    def attendee=(*ruby_values)
      attendee_property= ruby_values.map {|val| CalAddressValue.convert(val)}
    end

    def attendee_property # :nodoc:
      @attendee_property ||= []
    end

    def attendee_property_from_string(line) # :nodoc:
      attendee_property << CalAddressValue.new(line)
    end

    # return the value of the CATEGORIES property
    # which will be an array of instances of Array
    # see RFC 2445 4.8.1.4 pp 78-79
    def categories
      categories_property.map {|prop| prop.value}
    end

    # set the CATEGORIES property
    # one or more instances of Array may be passed to this method
    def categories=(*ruby_values)
      categories_property= ruby_values.map {|val| ArrayValue.convert(val)}
    end

    def categories_property # :nodoc:
      @categories_property ||= []
    end

    def categories_property_from_string(line) # :nodoc:
      categories_property << ArrayValue.new(line)
    end

    # return the value of the COMMENT property
    # which will be an array of instances of String
    # see RFC 2445 4.8.1.4 pp 80-81
    def comment
      comment_property.map {|prop| prop.value}
    end

    # set the COMMENT property
    # one or more instances of String may be passed to this method
    def comment=(*ruby_values)
      comment_property= ruby_values.map {|val| TextValue.convert(val)}
    end

    def comment_property # :nodoc:
      @comment_property ||= []
    end

    def comment_property_from_string(line) # :nodoc:
      comment_property << TextValue.new(line)
    end

    # return the value of the CONTACT property
    # which will be an array of instances of String
    # see RFC 2445 4.8.4.2 pp 104-106
    def contact
      contact_property.map {|prop| prop.value}
    end

    # set the CONTACT property
    # one or more instances of String may be passed to this method
    def contact=(*ruby_values)
      contact_property= ruby_values.map {|val| TextValue.convert(val)}
    end

    def contact_property # :nodoc:
      @contact_property ||= []
    end

    def contact_property_from_string(line) # :nodoc:
      contact_property << TextValue.new(line)
    end

    # return the value of the EXDATE property
    # which will be an array of instances of DateList
    # see RFC 2445 4.8.5.1 pp 112-114
    def exdate
      exdate_property.map {|prop| prop.value}
    end

    # set the EXDATE property
    # one or more instances of DateList may be passed to this method
    def exdate=(*ruby_values)
      exdate_property= ruby_values.map {|val| DateListValue.convert(val)}
    end

    def exdate_property # :nodoc:
      @exdate_property ||= []
    end

    def exdate_property_from_string(line) # :nodoc:
      exdate_property << DateListValue.new(line)
    end

    # return the value of the RDATE property
    # which will be an array of instances of DateList
    # see RFC 2445 4.8.5.3 pp 115-117
    def rdate
      rdate_property.map {|prop| prop.value}
    end

    # set the RDATE property
    # one or more instances of DateList may be passed to this method
    def rdate=(*ruby_values)
      rdate_property= ruby_values.map {|val| DateListValue.convert(val)}
    end

    def rdate_property # :nodoc:
      @rdate_property ||= []
    end

    def rdate_property_from_string(line) # :nodoc:
      rdate_property << DateListValue.new(line)
    end

    # return the value of the EXRULE property
    # which will be an array of instances of RecurrenceRule
    # see RFC 2445 4.8.5.2 pp 114-125
    def exrule
      exrule_property.map {|prop| prop.value}
    end

    # set the EXRULE property
    # one or more instances of RecurrenceRule may be passed to this method
    def exrule=(*ruby_values)
      exrule_property= ruby_values.map {|val| RecurrenceRuleValue.convert(val)}
    end

    def exrule_property # :nodoc:
      @exrule_property ||= []
    end

    def exrule_property_from_string(line) # :nodoc:
      exrule_property << RecurrenceRuleValue.new(line)
    end

    # return the value of the REQUEST-STATUS property
    # which will be an array of instances of String
    # see RFC 2445 4.8.8.2 pp 134-136
    def request_status
      request_status_property.map {|prop| prop.value}
    end

    # set the REQUEST-STATUS property
    # one or more instances of String may be passed to this method
    def request_status=(*ruby_values)
      request_status_property= ruby_values.map {|val| TextValue.convert(val)}
    end

    def request_status_property # :nodoc:
      @request_status_property ||= []
    end

    def request_status_property_from_string(line) # :nodoc:
      request_status_property << TextValue.new(line)
    end

    # return the value of the RELATED-TO property
    # which will be an array of instances of String
    # see RFC 2445 4.8.4.5 pp 109-110
    def related_to
      related_to_property.map {|prop| prop.value}
    end

    # set the RELATED-TO property
    # one or more instances of String may be passed to this method
    def related_to=(*ruby_values)
      related_to_property= ruby_values.map {|val| TextValue.convert(val)}
    end

    def related_to_property # :nodoc:
      @related_to_property ||= []
    end

    def related_to_property_from_string(line) # :nodoc:
      related_to_property << TextValue.new(line)
    end

    # return the value of the RESOURCES property
    # which will be an array of instances of Array
    # see RFC 2445 4.8.1.10 pp 87-88
    def resources
      resources_property.map {|prop| prop.value}
    end

    # set the RESOURCES property
    # one or more instances of Array may be passed to this method
    def resources=(*ruby_values)
      resources_property= ruby_values.map {|val| ArrayValue.convert(val)}
    end

    def resources_property # :nodoc:
      @resources_property ||= []
    end

    def resources_property_from_string(line) # :nodoc:
      resources_property << ArrayValue.new(line)
    end

    # return the value of the RRULE property
    # which will be an array of instances of RecurrenceRule
    # see RFC 2445 4.8.5.4 pp 117-117
    def rrule
      rrule_property.map {|prop| prop.value}
    end

    # set the RRULE property
    # one or more instances of RecurrenceRule may be passed to this method
    def rrule=(*ruby_values)
      rrule_property= ruby_values.map {|val| RecurrenceRuleValue.convert(val)}
    end

    def rrule_property # :nodoc:
      @rrule_property ||= []
    end

    def rrule_property_from_string(line) # :nodoc:
      rrule_property << RecurrenceRuleValue.new(line)
    end

    def self.property_parser
      {"RELATED-TO"=>:related_to_property_from_string, "RDATE"=>:rdate_property_from_string, "DTEND"=>:dtend_property_from_string, "DTSTART"=>:dtstart_property_from_string, "TRANSP"=>:transp_property_from_string, "DTSTAMP"=>:dtstamp_property_from_string, "LOCATION"=>:location_property_from_string, "EXRULE"=>:exrule_property_from_string, "CONTACT"=>:contact_property_from_string, "URL"=>:url_property_from_string, "LAST-MODIFIED"=>:last_modified_property_from_string, "RESOURCES"=>:resources_property_from_string, "EXDATE"=>:exdate_property_from_string, "ATTACH"=>:attach_property_from_string, "UID"=>:uid_property_from_string, "SEQUENCE"=>:sequence_property_from_string, "CATEGORIES"=>:categories_property_from_string, "RECURRENCE-ID"=>:recurrence_id_property_from_string, "SUMMARY"=>:summary_property_from_string, "GEO"=>:geo_property_from_string, "CLASS"=>:security_class_property_from_string, "RRULE"=>:rrule_property_from_string, "STATUS"=>:status_property_from_string, "ATTENDEE"=>:attendee_property_from_string, "PRIORITY"=>:priority_property_from_string, "ORGANIZER"=>:organizer_property_from_string, "CREATED"=>:created_property_from_string, "REQUEST-STATUS"=>:request_status_property_from_string, "COMMENT"=>:comment_property_from_string, "DURATION"=>:duration_property_from_string, "DESCRIPTION"=>:description_property_from_string}
    end

    def mutual_exclusion_violation
      return true if [:dtend_property, :duration_property].inject(0) {|sum, prop| send(prop) ? sum + 1 : sum} > 1
      false
    end
    # END GENERATED ATTRIBUTE CODE

   end
end
