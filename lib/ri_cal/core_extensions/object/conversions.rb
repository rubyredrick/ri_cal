module RiCal
  module CoreExtensions
    module Object
      module Conversions
        def to_rfc2445_string
          to_s
        end
        
        def to_ruby_value
          self
        end
      end
    end
  end
end