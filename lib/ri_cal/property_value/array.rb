module RiCal
  class PropertyValue
    class Array < PropertyValue # :nodoc:

      def value=(string)
        @value = string.split(",")
      end
    end
  end

end