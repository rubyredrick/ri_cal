require File.expand_path(File.join(File.dirname(__FILE__), 'ventity'))

module RiCal
  class Vcalendar < Ventity

    text_properties "calscale", "method", "prodid", "version"

  end
end