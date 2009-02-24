require File.join(File.dirname(__FILE__), %w[.. .. properties timezone_period.rb])

module RiCal
  class Component
    class Timezone
      # A TimezonePeriod is a component of a timezone representing a period during which a particular offset from UTC is
      # in effect.
      class TimezonePeriod < Component
        include Properties::TimezonePeriod
      end
    end
  end
end
