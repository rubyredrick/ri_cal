module RiCal

  class IntegerValue < PropertyValue

    def value=(string)
      @value = string.to_i 
    end
  end

end