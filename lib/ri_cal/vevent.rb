module RiCal
  # 
  class Vevent < Ventity
    # BEGIN GENERATED ATTRIBUTE CODE
    # # The following are optional but must not occur more than once RFC2445 - p52-53

    attr_accessor :security_class_property

    def security_class_property_from_string(line)
      @security_class_property = TextValue.new(line)
    end

    def security_class
      security_class_property.value
    end

    attr_accessor :created_property

    def created_property_from_string(line)
      @created_property = DateTimeValue.new(line)
    end

    def created
      created_property.value
    end

    attr_accessor :description_property

    def description_property_from_string(line)
      @description_property = TextValue.new(line)
    end

    def description
      description_property.value
    end

    attr_accessor :dtstart_property

    def dtstart_property_from_string(line)
      @dtstart_property = DateTimeValue.from_separated_line(line)
    end

    def dtstart
      dtstart_property.value
    end

    attr_accessor :geo_property

    def geo_property_from_string(line)
      @geo_property = TextValue.new(line)
    end

    def geo
      geo_property.value
    end

    attr_accessor :last_modified_property

    def last_modified_property_from_string(line)
      @last_modified_property = DateTimeValue.new(line)
    end

    def last_modified
      last_modified_property.value
    end

    attr_accessor :location_property

    def location_property_from_string(line)
      @location_property = TextValue.new(line)
    end

    def location
      location_property.value
    end

    attr_accessor :organizer_property

    def organizer_property_from_string(line)
      @organizer_property = CalAddressValue.new(line)
    end

    def organizer
      organizer_property.value
    end

    attr_accessor :priority_property

    def priority_property_from_string(line)
      @priority_property = IntegerValue.new(line)
    end

    def priority
      priority_property.value
    end

    attr_accessor :dtstamp_property

    def dtstamp_property_from_string(line)
      @dtstamp_property = DateTimeValue.new(line)
    end

    def dtstamp
      dtstamp_property.value
    end

    attr_accessor :sequence_property

    def sequence_property_from_string(line)
      @sequence_property = IntegerValue.new(line)
    end

    def sequence
      sequence_property.value
    end

    attr_accessor :status_property

    def status_property_from_string(line)
      @status_property = TextValue.new(line)
    end

    def status
      status_property.value
    end

    attr_accessor :summary_property

    def summary_property_from_string(line)
      @summary_property = TextValue.new(line)
    end

    def summary
      summary_property.value
    end

    attr_accessor :transp_property

    def transp_property_from_string(line)
      @transp_property = TextValue.new(line)
    end

    def transp
      transp_property.value
    end

    attr_accessor :uid_property

    def uid_property_from_string(line)
      @uid_property = TextValue.new(line)
    end

    def uid
      uid_property.value
    end

    attr_accessor :url_property

    def url_property_from_string(line)
      @url_property = UriValue.new(line)
    end

    def url
      url_property.value
    end

    attr_accessor :recurrence_id_property

    def recurrence_id_property_from_string(line)
      @recurrence_id_property = DateTimeValue.from_separated_line(line)
    end

    def recurrence_id
      recurrence_id_property.value
    end
    # 
    # # Either 'dtend' or 'duration' may appear in a 'eventprop' but 'dtend' and 'duration' may not
    # # occur in the same 'eventprop'  RFC 2445 p 53
    # 

    attr_accessor :dtend_property

    def dtend_property_from_string(line)
      @dtend_property = DateTimeValue.from_separated_line(line)
    end

    def dtend
      dtend_property.value
    end

    attr_accessor :duration_property

    def duration_property_from_string(line)
      @duration_property = DurationValue.new(line)
    end

    def duration
      duration_property.value
    end
    # 
    # # the following are optional and MAY occur more than once RFC 2445 p 53

    def attach_property
      @attach_property ||= []
    end

    def attach_property_from_string(line)
      attach_property << TextValue.new(line)
    end

    def attach
      attach_property.map {|prop| prop.value}
    end

    def attendee_property
      @attendee_property ||= []
    end

    def attendee_property_from_string(line)
      attendee_property << CalAddressValue.new(line)
    end

    def attendee
      attendee_property.map {|prop| prop.value}
    end

    def categories_property
      @categories_property ||= []
    end

    def categories_property_from_string(line)
      categories_property << ArrayValue.new(line)
    end

    def categories
      categories_property.map {|prop| prop.value}
    end

    def comment_property
      @comment_property ||= []
    end

    def comment_property_from_string(line)
      comment_property << TextValue.new(line)
    end

    def comment
      comment_property.map {|prop| prop.value}
    end

    def contact_property
      @contact_property ||= []
    end

    def contact_property_from_string(line)
      contact_property << TextValue.new(line)
    end

    def contact
      contact_property.map {|prop| prop.value}
    end

    def exdate_property
      @exdate_property ||= []
    end

    def exdate_property_from_string(line)
      exdate_property << DateListValue.new(line)
    end

    def exdate
      exdate_property.map {|prop| prop.value}
    end

    def rdate_property
      @rdate_property ||= []
    end

    def rdate_property_from_string(line)
      rdate_property << DateListValue.new(line)
    end

    def rdate
      rdate_property.map {|prop| prop.value}
    end

    def exrule_property
      @exrule_property ||= []
    end

    def exrule_property_from_string(line)
      exrule_property << RecurrenceRuleValue.new(line)
    end

    def exrule
      exrule_property.map {|prop| prop.value}
    end

    def request_status_property
      @request_status_property ||= []
    end

    def request_status_property_from_string(line)
      request_status_property << TextValue.new(line)
    end

    def request_status
      request_status_property.map {|prop| prop.value}
    end

    def related_to_property
      @related_to_property ||= []
    end

    def related_to_property_from_string(line)
      related_to_property << TextValue.new(line)
    end

    def related_to
      related_to_property.map {|prop| prop.value}
    end

    def resources_property
      @resources_property ||= []
    end

    def resources_property_from_string(line)
      resources_property << ArrayValue.new(line)
    end

    def resources
      resources_property.map {|prop| prop.value}
    end

    def rrule_property
      @rrule_property ||= []
    end

    def rrule_property_from_string(line)
      rrule_property << RecurrenceRuleValue.new(line)
    end

    def rrule
      rrule_property.map {|prop| prop.value}
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
