$:.unshift File.expand_path("../../lib", __FILE__)

require 'magent'

class Worker
  include Magent::Async

  def self.work()
    if rand < 0.95
      puts "failed!"
      raise "try again"
    else
      puts "OK!"
    end
  end
end
Worker.async(:queue1).work


# open the queue1 and process the messages
channel = Magent::AsyncChannel.new(:queue1)
processor = Magent::Processor.new(channel)

processor.run!(true)

