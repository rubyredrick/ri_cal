module RiCal
  class Vcalendar < Ventity
    # BEGIN GENERATED ATTRIBUTE CODE

    attr_accessor :calscale_property

    def calscale_property_from_string(line)
      @calscale_property = TextValue.new(line)
    end

    def calscale
      calscale_property.value
    end

    attr_accessor :method_property

    def method_property_from_string(line)
      @method_property = TextValue.new(line)
    end

    def method
      method_property.value
    end

    attr_accessor :prodid_property

    def prodid_property_from_string(line)
      @prodid_property = TextValue.new(line)
    end

    def prodid
      prodid_property.value
    end

    attr_accessor :version_property

    def version_property_from_string(line)
      @version_property = TextValue.new(line)
    end

    def version
      version_property.value
    end

    def self.property_parser
      {"METHOD"=>:method_property_from_string, "VERSION"=>:version_property_from_string, "PRODID"=>:prodid_property_from_string, "CALSCALE"=>:calscale_property_from_string}
    end

    def mutual_exclusion_violation
      false
    end
    # END GENERATED ATTRIBUTE CODE

  end
end
