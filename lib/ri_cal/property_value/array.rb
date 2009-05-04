#- ©2009 Rick DeNatale
#- All rights reserved

module RiCal
  class PropertyValue
    class Array < PropertyValue # :nodoc:

      def value=(val)
        case val
        when String
          @value = val.split(",")
        else
          @value = val
        end
      end
    end
  end

end