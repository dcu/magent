module Magent
  class Processor
    def initialize(channel)
      @channel = channel
      @shutdown = false

#       @actor.class.actions.each do |action|
#         if !@actor.respond_to?(action)
#           raise ArgumentError, "action '#{action}' is not defined"
#         end
#       end
    end

    def run!
      processed_messages = 0
      delay = 0

      trap('TERM') { shutdown!; exit 0 }
      trap('SIGINT') { shutdown!; exit 0 }

      loop do
        break if @shutdown

        message = @channel.dequeue
        begin
          if message && @channel.process!(message)
            delay = 0
            processed_messages += 1
            if processed_messages > 20
              processed_messages = 0
              GC.start
            end
          else
            delay += 0.1 if delay <= 5
          end
        rescue SystemExit
        rescue Exception => e
          @channel.failed(:error => e.message, :message => message, :backtrace => e.backtrace, :date => Time.now.utc)
        ensure
        end

        sleep delay
      end
    end

    def shutdown!
      @shutdown = true
      @channel.on_shutdown if @channel.respond_to?(:on_shutdown)
      $stderr.puts "Shutting down..."
    end
  end #Processor
end
