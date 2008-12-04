require File.expand_path(File.join(File.dirname(__FILE__), 'ventity'))

module RiCal
  class Vevent < Ventity
    text_properties "attach", "comment", "description", "status", "summary", "contact", "uid"
    text_property "geo"
    #TODO: should parse alt-rep parameter
    text_property "location"
    named_property "class", "security_class"
    array_properties "categories", "resources"
    integer_property "priority"
    date_time_or_date_properties "dtend", "dtstart", "recurrence-id"
    duration_property "duration"
    text_property "transp"
    text_property "related-to"
    cal_address_properties "attendee", "organizer"
    uri_property "url"
    date_list_properties "exdate", "rdate"
   end
end