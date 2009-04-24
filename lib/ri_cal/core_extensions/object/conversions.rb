module RiCal
  module CoreExtensions #:nodoc:
    module Object #:nodoc:
      module Conversions
        # Used to format rfc2445 output for RiCal
        def to_rfc2445_string
          to_s
        end
        
        # Used by RiCal specs returns the receiver
        def to_ri_cal_ruby_value
          self
        end
      end
    end
  end
end