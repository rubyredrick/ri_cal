require 'date'
module RiCal
  class PropertyValue
    #- ©2009 Rick DeNatale, All rights reserved. Refer to the file README.txt for the license
    #
    # RiCal::PropertyValue::CalAddress represents an icalendar CalAddress property value
    # which is defined in RFC 2445 section 4.3.5 pp 35-37
    class ZuluDateTime < PropertyValue::DateTime

      def value=(val) # :nodoc:
        super
        @date_time_value = @date_time_value.utc if @date_time_value
      end
    end
  end
end