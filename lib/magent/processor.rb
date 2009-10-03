module Magent
  class Processor
    attr_reader :actor

    def initialize(actor)
      @actor = actor
    end

    def run!
      delay = 0
      loop do
        method, payload = @actor.class.channel.dequeue

        if method.nil?
          delay += 0.1 if delay <= 10
        else
          delay = 0
          $stderr.puts "#{@actor.class}##{method}(#{payload.inspect})"
          @actor.send(method, payload) # TODO: what if method is not defined?
        end

        sleep delay
      end
    end
  end #Processor
end
