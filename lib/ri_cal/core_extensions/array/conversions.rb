module RiCal
  module CoreExtensions
    module Array
      module Conversions
        def to_rfc2445_string
          join(",")
        end
      end
    end
  end
end