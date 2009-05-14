module RiCal
  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      #- ©2009 Rick DeNatale
      #- All rights reserved. Refer to the file README.txt for the license
      #
      # Provides a tzid attribute for ::Time and ::DateTime
      module TzidAccess
        # The tzid attribute is used by RiCal, it should be a valid timezone identifier within a calendar,
        # :floating to indicate a floating time, or nil to use the default timezone in effect
        #
        # See PropertyValue::DateTime#default_tzid= and Component::Calendar#tzid=
        attr_accessor :tzid

        # Convenience method, sets the tzid and returns the receiver
        def set_tzid(time_zone_identifier)
          self.tzid = time_zone_identifier
          self
        end
      end
    end
  end

  module TimeWithZoneExtension #:nodoc:
    def tzid
      time_zone.tzid.identifier
    end
  end
end

if Object.const_defined?(:ActiveSupport)
  as = Object.const_get(:ActiveSupport)
  if as.const_defined?(:TimeWithZone)
    twz = as.const_get(:TimeWithZone)
    twz.class_eval {include RiCal::TimeWithZoneExtension}
  end
end