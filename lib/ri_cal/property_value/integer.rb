module RiCal
  class PropertyValue
    class Integer < PropertyValue # :nodoc:

      def value=(string)
        @value = string.to_i 
      end
    end
  end
end