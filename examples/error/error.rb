$:.unshift File.dirname(__FILE__)+"/../../lib/"
require 'magent'

Magent.push("/errors", :fail, "this is a fail")

class Error
  include Magent::Actor

  channel_name "errors"
  expose :fail

  def fail(payload)
    @count ||= 0
    errors = self.class.channel.errors

    errors.each do |error|
      @count += 1
      $stderr.puts "Retrying: #{error["method"]}(#{error["payload"].inspect})"
      self.class.channel.retry_error(error)
    end

    if @count == 0
      raise payload.inspect
    end
  end
end

Magent.register(Error.new)

if $0 == __FILE__
  Magent::Processor.new(Magent.current_actor).run!
end

