module RiCal
  class Vcalendar < Ventity
    # BEGIN GENERATED ATTRIBUTE CODE

    # return the the CALSCALE property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.7.1 p 73
    def calscale_property
      @calscale_property ||= []
    end

    # set the the CALSCALE property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def calscale_property=(property_values)
      calscale_property = property_value
    end

    # return the value of the CALSCALE property
    # which will be an instance of String
    def calscale
      calscale_property.value
    end

    # set the value of the CALSCALE property
    def calscale=(*ruby_values)
      calscale_property= TextValue.convert(ruby_val)
    end

    attr_accessor :calscale_property

    def calscale_property_from_string(line) # :nodoc:
      @calscale_property = TextValue.new(line)
    end


    # return the the METHOD property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.7.2 p 74-75
    def method_property
      @method_property ||= []
    end

    # set the the METHOD property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def method_property=(property_values)
      method_property = property_value
    end

    # return the value of the METHOD property
    # which will be an instance of String
    def icalendar_method
      method_property.value
    end

    # set the value of the METHOD property
    def icalendar_method=(*ruby_values)
      method_property= TextValue.convert(ruby_val)
    end

    attr_accessor :method_property

    def method_property_from_string(line) # :nodoc:
      @method_property = TextValue.new(line)
    end


    # return the the PRODID property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.7.3 pp 75-76
    def prodid_property
      @prodid_property ||= []
    end

    # set the the PRODID property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def prodid_property=(property_values)
      prodid_property = property_value
    end

    # return the value of the PRODID property
    # which will be an instance of String
    def prodid
      prodid_property.value
    end

    # set the value of the PRODID property
    def prodid=(*ruby_values)
      prodid_property= TextValue.convert(ruby_val)
    end

    attr_accessor :prodid_property

    def prodid_property_from_string(line) # :nodoc:
      @prodid_property = TextValue.new(line)
    end


    # return the the VERSION property
    # which will be an instances of RiCal::TextValue
    # see RFC 2445 4.7.4 pp 76-77
    def version_property
      @version_property ||= []
    end

    # set the the VERSION property
    # property_value should be an instance of RiCal::TextValue may be passed to this method
    def version_property=(property_values)
      version_property = property_value
    end

    # return the value of the VERSION property
    # which will be an instance of String
    def version
      version_property.value
    end

    # set the value of the VERSION property
    def version=(*ruby_values)
      version_property= TextValue.convert(ruby_val)
    end

    attr_accessor :version_property

    def version_property_from_string(line) # :nodoc:
      @version_property = TextValue.new(line)
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
