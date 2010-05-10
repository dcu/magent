module Magent
  class GenericChannel
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def enqueue(message)
      collection.save({:_id => generate_uid, :message => message, :priority => 3, :created_at => Time.now.to_i})
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
      Magent.database.command(BSON::OrderedHash[:findandmodify, @name,
                               :sort, [{:priority => -1}, {:created_at => 1}],
                               :remove, true
                              ])["value"]
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
