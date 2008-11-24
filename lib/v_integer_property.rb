module Rfc2445

  class VIntegerProperty < VProperty

    def value=(string)
      @value = string.to_i 
    end
  end

end