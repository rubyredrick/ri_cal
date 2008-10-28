module Rfc2445

  class Vproperty

    attr_accessor :name, :params, :value
    def initialize(separated_line)
      @name = separated_line[:name]
      @params = separated_line[:params]
      @value = separated_line[:value]
    end

  end
  
  class VTextProperty < Vproperty
  end

end