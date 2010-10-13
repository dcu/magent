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

    # TODO: move to its own module
    def failed(info)
      error_collection.save(info.merge({:_id => generate_uid, :channel => @name, :created_at => Time.now.utc}))
    end

    def error_count
      error_collection.count()
    end

    def errors(conds = {})
      page = conds.delete(:page) || 1
      per_page = conds.delete(:per_page) || 10

      error_collection.find({}, {:skip => (page-1)*per_page,
                                 :limit => per_page,
                                 :sort => [["created_at", -1]]})
    end

    def remove_error(error_id)
      self.error_collection.remove(:_id => error_id)
    end

    def retry_error(error)
      remove_error(error["_id"])
      enqueue(error["method"], error["payload"])
    end

    def error_collection
      @error_collection ||= Magent.database.collection("#{@name}-errors")
    end
  end # Channel
end
