module RiCal
  #- ©2009 Rick DeNatale
  #- All rights reserved. Refer to the file README.txt for the license
  #
  # An InvalidPropertyValue error is raised when an improper value is assigned to a property
  #
  # Rather than attempting to detect invalid timezones immediately the detection is deferred to avoid problems
  # such as importing a calendar which has forward reference to VTIMEZONE components.
  class InvalidPropertyValue < StandardError
  end
end
