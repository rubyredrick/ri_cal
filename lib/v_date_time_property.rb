require File.join(File.dirname(__FILE__), 'v_property')
module RiCal

  class VDateTimeProperty < VProperty

    def self.from_separated_line(line)
      if /T/.match(line[:value] || "")
        new(line)
      else
        VDateProperty.new(line)
      end
    end 

    def tzid
      params && params[:tzid]
    end    
  end

end