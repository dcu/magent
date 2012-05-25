module Magent
  class Processor
    def initialize(channel, identity = "#{channel.name}-#{Socket.gethostname.split('.')[0]}")
      @channel = channel
      @shutdown = false
      @identity = identity

      @channel.on_start(identity)
    end

    def run!(service = true)
      processed_messages = 0
      delay = 0

      trap('TERM') { shutdown!; exit 0 }
      trap('SIGINT') { shutdown!; exit 0 }

      loop do
        break if @shutdown

        message = @channel.dequeue
        begin
          t = Time.now
          if message && @channel.process!(message)
            puts "Processed #{message.inspect}"

            @channel.on_job_processed(@channel.current_job, Time.now - t, @identity)

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
          $stderr.puts "Error processing #{message.inspect} => #{e.message}"
          @channel.on_job_failed(@identity)
          @channel.failed(:error => e.message, :message => message, :backtrace => e.backtrace, :date => Time.now.utc)
        ensure
        end

        break if !service

        sleep (delay*100.0).to_i/100.0
      end
    end

    def shutdown!
      @shutdown = true
      @channel.on_quit(@identity)

      @channel.on_shutdown if @channel.respond_to?(:on_shutdown)
      $stderr.puts "Shutting down..."
    end
  end #Processor
end
