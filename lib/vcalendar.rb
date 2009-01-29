require File.expand_path(File.join(File.dirname(__FILE__), 'ventity'))

module RiCal
  class Vcalendar < Ventity

    property "calscale"
    property "method"
    property "prodid"
    property "version"

  end
end