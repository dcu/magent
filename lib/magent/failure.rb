module Magent
  module Failure
    def failed(info)
      error_collection.save(info.merge({
        :_id => generate_uid,
        :channel => @name,
        :channel_class => self.class.to_s,
        :created_at => Time.now.utc
      }))
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
      process!(error["message"])
      remove_error(error["_id"])
    end

    def enqueue_error(error)
      enqueue(error["message"], 1)
      remove_error(error["_id"])
    end

    def error_collection
      @error_collection ||= Magent.database.collection("#{@name}.errors")
    end
  end
end
