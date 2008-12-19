module RiCal

  class ArrayValue < PropertyValue

    def value=(string)
      @value = string.split(",")
    end
  end

end