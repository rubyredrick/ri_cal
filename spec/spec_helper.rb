#- ©2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license

require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib ri_cal]))
require 'cgi'

module Kernel
  def rputs(*args)
    puts *["<pre>", args.collect {|a| CGI.escapeHTML(a.to_s)}, "</pre>"] #if RiCal.debug
    # puts *args
  end
end

def date_time_with_zone(date_time, tzid = "US/Eastern")
  date_time.dup.set_tzid(tzid)
end

def dt_prop(date_time, tzid = "US/Eastern")
  RiCal::PropertyValue::DateTime.convert(nil, date_time_with_zone(date_time, tzid))
end
