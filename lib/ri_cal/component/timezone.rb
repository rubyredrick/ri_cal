module RiCal
  class Component
    class Timezone < Component

      def self.entity_name #:nodoc:
        "VTIMEZONE"
      end
    end
  end
end


%w[timezone_period.rb daylight_period.rb standard_period.rb].each do |filename|  
  require "#{File.dirname(__FILE__)}/timezone/#{filename}"
end