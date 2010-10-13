module Magent
  class GenericChannel
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def enqueue(message, priority = 3)
      collection.save({:_id => generate_uid, :message => message, :priority => priority, :created_at => Time.now.to_i})
    end

    def message_count
      collection.count # TODO: number of processed messages (create a collection for stats)
    end

    def queue_count
      collection.count
    end

    def dequeue
      if m = self.next_message
        m["message"]
      end
    end

    def next_message
      collection.find_and_modify(:sort => [[:priority, Mongo::ASCENDING], [:created_at, Mongo::DESCENDING]],
                                 :remove => true) rescue {}
    end

    def collection
      @collection ||= Magent.database.collection(@name)
    end

    protected
    def generate_uid
      UUIDTools::UUID.random_create.hexdigest
    end
  end # GenericChannel
end
