module Magent
  class GenericChannel
    def initialize(name)
      @name = name

      if !collection.find_one({:_id => @name}, {:fields => [:_id]})
        collection.save({:_id => @name, :messages => []})
      end
    end

    def enqueue(message)
      collection.update({:_id => @name}, {:$push => {:messages => message}}, :repsert => true)
    end

    def dequeue
      Magent.database.eval(%@
        function dequeue() {
          var selector = {_id: '#{@name}'};
          var q = db.channels.findOne(selector, {messages: 1 });
          var m = q.messages[0];
          if(m)
            db.channels.update(selector, { $pop: { messages : -1 } })
          return m;
        }
      @)
    end

    def collection
      self.class.collection
    end

    def self.collection
      @collection ||= Magent.database.collection("channels")
    end

    def self.all(&block)
      cursor = collection.find({}, :fields => [:_id])
      if block_given?
        cursor.map {|c| name = c["_id"]; yield name; name }
      else
        cursor.map {|c| c["_id"] }
      end
    end
  end # GenericChannel
end
