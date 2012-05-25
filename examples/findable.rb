$:.unshift File.expand_path("../../lib", __FILE__)

require 'magent'

class Findable
  attr_accessor :id
  def initialize(id)
    @id = id
  end

  def self.find(id)
    Findable.new(id)
  end

  def inspect
    "Findable<#{@id}>"
  end
end

class Manager
  include Magent::Async

  def self.process(findable)
    puts ">>> Proccessing: #{findable.inspect}"
  end
end

findable = Findable.new(19)
Manager.async(:queue1).process(findable)


# open the queue1 and process the messages
channel = Magent::AsyncChannel.new(:queue1)
processor = Magent::Processor.new(channel)

processor.run!(false)
