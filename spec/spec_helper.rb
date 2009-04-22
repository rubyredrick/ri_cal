require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib ri_cal]))
require 'cgi'

module Kernel
  def rputs(*args)
    puts *["<pre>", args.collect {|a| CGI.escapeHTML(a.to_s)}, "</pre>"] #if RiCal.debug
    # puts *args
  end
end

def date_time_with_zone(date_time, tzid = "US/Eastern")
  result = date_time.dup
  result.stub!(:acts_like_time?).and_return(true)
  time_zone = mock("timezone", :identifier => tzid)
  result.stub!(:time_zone).and_return(time_zone)
  result
end

def dt_prop(date_time, tzid = "US/Eastern")
  RiCal::PropertyValue::DateTime.convert(date_time_with_zone(date_time, tzid))
end
