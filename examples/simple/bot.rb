$:.unshift File.dirname(__FILE__)+"/../../lib/"
require 'magent'

Magent.push("/bot", :echo, "Press ctrl+c to close")
Magent.push("/bot", :do_task, "File", :exist?, "/etc/passwd")
Magent.push("/bot", :echo, "hello, world")

class Bot
  include Magent::Actor

  expose :echo, :do_task

  def echo(payload)
    $stderr.puts payload.inspect
  end

  def do_task(payload)
    klass, *args = payload

    result = Object.module_eval(klass).send(*args)
    $stderr.puts "RESULT: #{result}"
  end

end

Magent::Processor.new(Bot.new).run!

