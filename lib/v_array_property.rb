module RiCal

  class VArrayProperty < VProperty

    def value=(string)
      @value = string.split(",")
    end
  end

end