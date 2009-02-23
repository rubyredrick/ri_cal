module RiCal
  class PropertyValue
    class Array < PropertyValue

      def value=(string)
        @value = string.split(",")
      end
    end
  end

end