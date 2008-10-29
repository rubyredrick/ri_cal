require File.expand_path(File.join(File.dirname(__FILE__), 'ventity'))

module Rfc2445
  class Vcalendar < Ventity

    text_properties "calscale", "method", "prodid", "version"

  end
end