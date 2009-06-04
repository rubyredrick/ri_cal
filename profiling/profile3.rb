require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib ri_cal]))
require 'rubygems'
require "benchmark"

calendar_file = File.open(File.join(File.dirname(__FILE__), *%w[ical_files profile3.ics]), 'r')
calendar = RiCal.parse(calendar_file).first
cutoff = Date.parse("20100531")
def code_to_profile(calendar, cutoff, out=STDOUT)
  calendar.events.each do |event|
    event.occurrences(:before => cutoff).each do |instance|
      out.puts "Event #{instance.uid.slice(0..5)}, starting #{instance.dtstart}, ending #{instance.dtend}"
    end 
  end
end

devnul = Object.new
def devnul.puts(string)
end

Benchmark.bmbm do |results|
  results.report("Benchmark:") { code_to_profile(calendar, cutoff, devnul) }
end

require 'ruby-prof'

result = RubyProf.profile do
  code_to_profile(calendar, cutoff)
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(File.open("callgrind.out", 'w'))