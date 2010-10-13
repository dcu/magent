$:.unshift File.dirname(__FILE__)+"/../../lib/"
require 'magent'

# Use: magent /path/to/this/file

class Worker
  include Magent::Actor
  channel_name "workers"
  expose :sum

  def sum(payload)
    id, *args = payload

    s = args.inject(0) { |v, a| a += v }
    send_to_client(id, {:method => :sum, :result => s})
  end

  private
  def send_to_client(id, message)
    c = Magent::GenericChannel.new("+#{id}")
    c.enqueue(message)
  end
end

Magent.register(Worker.new)

if $0 == __FILE__
  Magent::Processor.new(Worker.channel).run!
end

