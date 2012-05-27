class Model
  attr_accessor :id
  def initialize(id)
    @id = id.to_s
  end

  def self.find(id)
    Model.new(id)
  end

  def inspect
    "Model<#{@id.inspect}>"
  end

  def ==(v)
    self.id == v.id
  end

  def <=>(v)
    return false if v.nil?
    self.id <=> v.id
  end
end
