module RiCal
  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      #- ©2009 Rick DeNatale
      #- All rights reserved. Refer to the file README.txt for the license
      #
      # Provides a tzid attribute for ::Time and ::DateTime
      module TzidAccess
        # The tzid attribute is used by RiCal, it should be a valid timezone identifier within a calendar
        attr_accessor :tzid

        # Convenience method, sets the tzid and returns the receiver
        def set_tzid(time_zone_identifier)
          self.tzid = time_zone_identifier
          self
        end
      end
    end
  end

  module TimeWithZoneExtension
    def tzid
      time_zone.tzid.identifier
    end
  end
end

if defined? ActiveSupport::TimeWithZone
  twz = Object.const_get(:ActiveSupport).const_get(:TimeWithZone)
  twz.class_eval {include RiCal::TimeWithZoneExtension}
end