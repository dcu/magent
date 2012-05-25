module Magent
  class GenericChannel
    include Magent::Failure
    include Magent::Stats

    attr_reader :name
    attr_reader :current_job

    def initialize(name)
      @name = "magent.#{name}"
    end

    def enqueue(message, priority = 3)
      collection.save({:_id => generate_uid, :message => message, :priority => priority, :created_at => Time.now.to_i, :retries => 0})
    end

    def message_count
      collection.count # TODO: number of processed messages (create a collection for stats)
    end

    def queue_count
      collection.count
    end

    def dequeue
      if @current_job = self.next_message
        @current_job["message"]
      end
    end

    def next_message
      collection.find_and_modify(:sort => [[:priority, Mongo::ASCENDING], [:created_at, Mongo::DESCENDING]],
                                 :remove => true) rescue {}
    end

    def collection
      @collection ||= Magent.database.collection(@name)
    end

    def retry_current_job
      return false if !@current_job

      @current_job['retries'] ||= 0
      if @current_job['retries'] < 20
        @current_job['retries'] += 1
        collection.save(@current_job)
        true
      else
        false
      end
    end

    protected
    def generate_uid
      UUIDTools::UUID.random_create.hexdigest
    end

    def async_find(klass, id)
      klass = Object.module_eval(klass) if klass.kind_of?(String)

      if id
        klass.find(id)
      else
        klass
      end
    end

    def encode_args(args)
      args.map! do |arg|
        if arg.class.respond_to?(:find) && arg.respond_to?(:id)
          {'async_find' => [arg.class.to_s, arg.id]}
        elsif arg.kind_of?(Class)
          {'async_find' => [arg.to_s, nil]}
        else
          arg
        end
      end
    end

    def resolve_args(args)
      args.map do |arg|
        if arg.kind_of?(Hash) && arg.include?('async_find')
          async_find(*arg['async_find'])
        else
          arg
        end
      end
    end
  end # GenericChannel
end
