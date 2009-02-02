module RiCal
  # 
  class Vevent < Ventity
    # The following are optional but must not occur more than once RFC2445 - p52-53
    property "class", :ruby_name => "security-class"
    property "created", :type => DateTimeValue
    property "description"
    property "dtstart", :type => 'date_time_or_date'
    property "geo"
    property "last-modified", :type => DateTimeValue
    property "location"
    property "organizer", :type => CalAddressValue
    property "priority", :type => IntegerValue
    property "dtstamp", :type => DateTimeValue
    property "sequence", :type => IntegerValue
    property "status"
    property "summary"
    property "transp"
    property "uid"
    property "url", :type => UriValue
    property "recurrence-id", :type => 'date_time_or_date'
    
    # Either 'dtend' or 'duration' may appear in a 'eventprop' but 'dtend' and 'duration' may not
    # occur in the same 'eventprop'  RFC 2445 p 53

    property "dtend", :type => 'date_time_or_date'
    property "duration", :type => DurationValue
    mutually_exclusive "dtend", "duration"

    # the following are optional and MAY occur more than once RFC 2445 p 53
    property "attach", :multi => true
    property "attendee", :type => CalAddressValue, :multi => true
    property "categories", :type => ArrayValue, :multi => true
    property "comment", :multi => true
    property "contact", :multi => true
    property "exdate", :type => DateListValue, :multi => true
    property "rdate", :type => DateListValue, :multi => true
    property "exrule", :type => RecurrenceRuleValue, :multi => true
    property "request-status", :multi => true
    property "related-to", :multi => true
    property "resources", :type => ArrayValue, :multi => true
    property "rrule", :type => RecurrenceRuleValue, :multi => true
   end
end