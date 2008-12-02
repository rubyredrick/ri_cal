module RiCal

  class VIntegerProperty < VProperty

    def value=(string)
      @value = string.to_i 
    end
  end

end