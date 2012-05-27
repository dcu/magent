class Custom
  attr_reader :a, :b
  def initialize(a, b)
    @a = a
    @b = b
  end

  def ==(v)
    @a == v.a && @b == v.b
  end
end