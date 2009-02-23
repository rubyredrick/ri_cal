module RiCal
  class PropertyValue
    class Integer < PropertyValue

      def value=(string)
        @value = string.to_i 
      end
    end
  end
end