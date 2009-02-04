module RiCal
  class Vcalendar < Ventity
    # BEGIN GENERATED ATTRIBUTE CODE

    # return the value of the CALSCALE property
    # which will be an instance of String
    # see RFC 2445 4.7.1 p 73
    def calscale
      calscale_property.value
    end

    # set the CALSCALE property
    def calscale=(*ruby_values)
      calscale_property= TextValue.convert(ruby_val)
    end

    attr_accessor :calscale_property

    def calscale_property_from_string(line) # :nodoc:
      @calscale_property = TextValue.new(line)
    end


    # return the value of the METHOD property
    # which will be an instance of String
    # see RFC 2445 4.7.2 p 74-75
    def icalendar_method
      icalendar_method_property.value
    end

    # set the METHOD property
    def icalendar_method=(*ruby_values)
      icalendar_method_property= TextValue.convert(ruby_val)
    end

    attr_accessor :icalendar_method_property

    def icalendar_method_property_from_string(line) # :nodoc:
      @icalendar_method_property = TextValue.new(line)
    end


    # return the value of the PRODID property
    # which will be an instance of String
    # see RFC 2445 4.7.3 pp 75-76
    def prodid
      prodid_property.value
    end

    # set the PRODID property
    def prodid=(*ruby_values)
      prodid_property= TextValue.convert(ruby_val)
    end

    attr_accessor :prodid_property

    def prodid_property_from_string(line) # :nodoc:
      @prodid_property = TextValue.new(line)
    end


    # return the value of the VERSION property
    # which will be an instance of String
    # see RFC 2445 4.7.4 pp 76-77
    def version
      version_property.value
    end

    # set the VERSION property
    def version=(*ruby_values)
      version_property= TextValue.convert(ruby_val)
    end

    attr_accessor :version_property

    def version_property_from_string(line) # :nodoc:
      @version_property = TextValue.new(line)
    end


    def self.property_parser
      {"METHOD"=>:icalendar_method_property_from_string, "VERSION"=>:version_property_from_string, "PRODID"=>:prodid_property_from_string, "CALSCALE"=>:calscale_property_from_string}
    end

    def mutual_exclusion_violation
      false
    end
    # END GENERATED ATTRIBUTE CODE

  end
end
