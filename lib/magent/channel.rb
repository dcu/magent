module Magent
  class Channel
    def initialize(name)
      @name = name

      if !collection.find_one({:_id => @name}, {:fields => [:_id]})
        collection.save({:_id => @name, :messages => [], :errors => []})
      end
    end

    def enqueue(message, args)
      collection.update({:_id => @name}, {:$push => {:messages => [message, args]}}, :repsert => true)
    end

    def failed(info)
      error_collection.save(info.merge({:channel_id => @name, :created_at => Time.now.utc}))
    end

    def errors(conds = {})
      page = conds.delete(:page) || 1
      per_page = conds.delete(:per_page) || 10

      error_collection.find({:channel_id => @name}, {:offset => (page-1)*per_page, :limit => per_page, :sort => ["created_at"]})
    end

    def dequeue
      Magent.database.eval(%@
        function dequeue() {
          return db.eval(function() {
            var q = db.channels.findOne({_id: '#{@name}'});
            var m = q.messages.shift();
            db.channels.save(q); //slow
            return m;
          });
        }
      @)
    end

    def collection
      self.class.collection
    end

    def error_collection
      @error_collection ||= Magent.database.collection("errors")
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
