module Magent
  class Channel
    def initialize(name)
      @name = name

      if !collection.find_one({:_id => @name}, {:fields => [:_id]})
        collection.save({:_id => @name, :messages => []})
      end
    end

    def enqueue(message, args)
      collection.update({:_id => @name}, {:$push => {:messages => [message, args]}}, :repsert => true)
    end

    def dequeue
      Magent.database.eval(%@
        function dequeue() {
          return db.eval(function() {
            var q = db.channels.findOne({_id: '#{@name}'});
            var m = q.messages.pop();
            db.channels.save(q); //slow
            return m;
          });
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
  end # Channel
end
