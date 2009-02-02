# The following are optional but must not occur more than once RFC2445 - p52-53
property "class", :ruby_name => "security-class"
property "created", :type => 'DateTime'
property "description"
property "dtstart", :type => 'date_time_or_date'
property "geo"
property "last-modified", :type => 'DateTime'
property "location"
property "organizer", :type => 'CalAddress'
property "priority", :type => 'Integer'
property "dtstamp", :type => 'DateTime'
property "sequence", :type => 'Integer'
property "status"
property "summary"
property "transp"
property "uid"
property "url", :type => 'Uri'
property "recurrence-id", :type => 'date_time_or_date'

# Either 'dtend' or 'duration' may appear in a 'eventprop' but 'dtend' and 'duration' may not
# occur in the same 'eventprop'  RFC 2445 p 53

property "dtend", :type => 'date_time_or_date'
property "duration", :type => 'Duration'
mutually_exclusive "dtend", "duration"

# the following are optional and MAY occur more than once RFC 2445 p 53
property "attach", :multi => true
property "attendee", :type => 'CalAddress', :multi => true
property "categories", :type => 'Array', :multi => true
property "comment", :multi => true
property "contact", :multi => true
property "exdate", :type => 'DateList', :multi => true
property "rdate", :type => 'DateList', :multi => true
property "exrule", :type => 'RecurrenceRule', :multi => true
property "request-status", :multi => true
property "related-to", :multi => true
property "resources", :type => 'Array', :multi => true
property "rrule", :type => 'RecurrenceRule', :multi => true
