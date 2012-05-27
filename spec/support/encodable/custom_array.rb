class CustomArray < Array
  def inspect
    "CustomArray<#{super}>"
  end
  alias :to_s :inspect
end