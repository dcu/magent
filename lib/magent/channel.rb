module Magent
  class Channel < GenericChannel
    def enqueue(message, args)
      super([message, args])
    end

    def failed(info)
      error_collection.save(info.merge({:channel_id => @name, :created_at => Time.now.utc}))
    end

    def errors(conds = {})
      page = conds.delete(:page) || 1
      per_page = conds.delete(:per_page) || 10

      error_collection.find({:channel_id => @name}, {:offset => (page-1)*per_page, :limit => per_page, :sort => ["created_at"]})
    end

    def error_collection
      @error_collection ||= Magent.database.collection("errors")
    end
  end # Channel
end
