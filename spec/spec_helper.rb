require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib ri_cal]))

module Kernel
  def rputs(*args)
    puts *["<pre>", args.collect {|a| CGI.escapeHTML(a.inspect)}, "</pre>"]
  end
end
