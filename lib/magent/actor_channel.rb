module Magent
  class ActorChannel < GenericChannel
    def enqueue(message, args)
      super([message, args])
    end

    def process!
      @actor = Magent.current_actor

      @method, @payload = self.dequeue
      return false if @method.nil?

      sucess = @actor._run_tasks

      $stderr.puts "#{@actor.class}##{@method}(#{@payload.inspect})"
      if @actor.class.can_handle?(@method)
        @actor.send(@method, @payload)
        return true
      else
        $stderr.puts "Unknown action: #{@method} (payload=#{@payload.inspect})"
      end

      @method, @payload = nil

      sucess
    end

    def on_shutdown
      if @method
        self.enqueue(@method, @payload)
      end
    end
  end # Channel
end
