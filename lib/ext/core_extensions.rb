class Object
  def to_rfc2445_string
    to_s
  end
end

class Array
  def to_rfc2445_string
    join(",")
  end
end