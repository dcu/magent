module Magent
  class Processor
    attr_reader :actor

    def initialize(actor)
      @actor = actor
      @shutdown = false

      @actor.class.actions.each do |action|
        if !@actor.respond_to?(action)
          raise ArgumentError, "action '#{action}' is not defined"
        end
      end
    end

    def run!
      processed_messages = 0
      delay = 0

      trap('TERM') { shutdown!; exit 0 }
      trap('SIGINT') { shutdown!; exit 0 }

      loop do
        break if @shutdown

        delay = 0 if @actor._run_tasks

        @method, @payload = @actor.class.channel.dequeue

        if @method.nil?
          delay += 0.1 if delay <= 5
        else
          delay = 0
          $stderr.puts "#{@actor.class}##{@method}(#{@payload.inspect})"
          begin
            if @actor.class.actions.include?(@method)
              processed_messages += 1
              @actor.send(@method, @payload)

              if processed_messages > 20
                processed_messages = 0
                GC.start
              end
            else
              $stderr.puts "Unknown action: #{@method} (payload=#{@payload.inspect})"
            end
          rescue SystemExit
          rescue Exception => e
            $stderr.puts "Error while executing #{@method.inspect} #{@payload.inspect}"
            $stderr.puts "#{e.to_s}\n#{e.backtrace.join("\t\n")}"
            @actor.class.channel.failed(:message => e.message, :method => @method, :payload => @payload, :backtrace => e.backtrace, :date => Time.now.utc)
          ensure
            @method, @payload = nil
          end
        end
        sleep delay
      end
    end

    def shutdown!
      @shutdown = true
      $stderr.puts "Shutting down..."
      if @method
        @actor.class.channel.enqueue(@method, @payload)
      end
    end
  end #Processor
end
