module Magent
  class Channel < GenericChannel
    def enqueue(message, args)
      super([message, args])
    end

    def failed(info)
      error_collection.save(info.merge({:channel_id => @name, :created_at => Time.now.utc}))
    end

    def error_count
      error_collection.find({:channel_id => @name}).count()
    end

    def errors(conds = {})
      page = conds.delete(:page) || 1
      per_page = conds.delete(:per_page) || 10

      error_collection.find({:channel_id => @name}, {:skip => (page-1)*per_page, :limit => per_page, :sort => [["created_at", "descending"]]})
    end

    def remove_error(error_id)
      object_id = error_id
      if error_id.kind_of?(String)
        object_id = Mongo::ObjectID.from_string(error_id)
      end

      self.error_collection.remove(:_id => object_id, :channel_id => @name)
    end

    def retry_error(error)
      remove_error(error["_id"])
      enqueue(error["method"], error["payload"])
    end

    def error_collection
      @error_collection ||= Magent.database.collection("errors")
    end
  end # Channel
end
