module Magent
  class Processor
    attr_reader :actor

    def initialize(actor)
      @actor = actor

      @actor.class.actions.each do |action|
        if !@actor.respond_to?(action)
          raise ArgumentError, "action '#{action}' is not defined"
        end
      end
    end

    def run!
      delay = 0
      loop do
        method, payload = @actor.class.channel.dequeue

        if method.nil?
          delay += 0.1 if delay <= 5
        else
          delay = 0
          $stderr.puts "#{@actor.class}##{method}(#{payload.inspect})"
          begin
            @actor.send(method, payload) # TODO: what if method is not defined?
          rescue Exception => e
            $stderr.puts "Error while executing #{method.inspect} #{payload.inspect}"
            $stderr.puts "#{e.to_s} #{e.backtrace.join("\t\n")}"
            @actor.class.channel.failed(:message => e.message, :method => method, :payload => payload, :backtrace => e.backtrace)
          end
        end

        sleep delay
      end
    end
  end #Processor
end
