module RiCal
  # A StandardPeriod is a TimezonePeriod during which daylight saving time is *not* in effect
  class StandardPeriod < TimezonePeriod

    def self.entity_name #:nodoc:
      "STANDARD"
    end
  end
end