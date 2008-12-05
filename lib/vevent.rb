require File.expand_path(File.join(File.dirname(__FILE__), 'ventity'))

module RiCal
  class Vevent < Ventity
    text_properties "attach", "comment", "description", "status", "summary", "contact", "uid", "request-status"
    text_property "geo"
    #TODO: should parse alt-rep parameter
    text_property "location"
    named_property "class", "security-class"
    array_properties "categories", "resources"
    integer_properties "priority", "sequence"
    date_time_or_date_properties "dtend", "dtstart", "recurrence-id"
    duration_property "duration"
    text_property "transp"
    text_property "related-to"
    cal_address_properties "attendee", "organizer"
    uri_property "url"
    date_list_properties "exdate", "rdate"
    recurrence_rule_properties "exrule", "rrule"
    date_time_properties "created", "dtstamp", "last-modified"
   end
end