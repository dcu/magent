$:.unshift File.dirname(__FILE__)+"/../../lib/"
require 'magent'

Magent.push("stats", :calc)
Magent.push("stats", :calc)
Magent.push("stats", :calc)
Magent.push("stats", :calc)

class Stats
  include Magent::Actor

  channel_name "stats"
  expose :calc

  def calc(payload)
    $stderr.puts "messages in queue: #{self.class.channel.queue_count}"
    $stderr.puts "total messages count: #{self.class.channel.message_count}"
    $stderr.puts "total errors: #{self.class.channel.error_count}"
  end
end

Magent.register(Stats.new)

if $0 == __FILE__
  Magent::Processor.new(Magent.current_actor).run!
end

