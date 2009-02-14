== RI_CAL -- a new implementation of RFC2445 in Ruby

    by Rick DeNatale
    http://talklikeaduck.denhaven2.com

== DESCRIPTION:

A new Ruby implementation of RFC2445 iCalendar.

The existing Ruby iCalendar libraries (e.g. icalendar, vpim) provide for parsing and generating icalendar files,
but do not support important things like enumerating occurrences of repeating events.

This is a clean-slate implementation of RFC2445.

== FEATURES/PROBLEMS:

* All examples of recurring events in RFC 2445 are handled. RSpec examples are provided for them. 

== SYNOPSIS:

  FIXME (code sample of usage)

== REQUIREMENTS:

* FIXME (list of requirements)

== INSTALL:

* FIXME (sudo gem install, anything else)

== LICENSE:

Copyright (c) 2009 Richard J. DeNatale

This software and associated documentation files (the
'Software') is an early access version.

A Restricted License is hereby granted, free of charge, 
to use the Software for evaluation and feedback only

This license does not grant you the permission to publish,
distribute, sublicense, or sell copies of the Software.

This licence applies to previous and future versions of the software, until such time
as a version is released with a licence granting additional rights,

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
