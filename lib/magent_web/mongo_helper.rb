module MagentWeb
  module MongoHelper
    def queues
      q = []
      Magent.database.collections.each do |collection|
        if collection.name =~ /^magent\./ && collection.name !~ /(errors|stats)$/
          q << collection
        end
      end

      q
    end

    def query_options
      options = {}
      options[:limit] = params[:limit].nil? ? 25 : params[:limit].to_i
      options[:sort] = [["_id", (params[:descending] == "true" ? 'descending' : 'ascending')]]
      options[:skip] = params[:skip].nil? ? 0 : params[:skip].to_i

      options
    end

    def document_list(collection, query = {})
      collection.find(query, query_options)
    end

    def file_size(database)
      "%0.2f MB" % (database.stats["fileSize"] / 1024**2)
    end

    def normalize_stats(stats)
      r={}
      stats.each do |k,v|
        if k =~ /size/i
          if v.kind_of?(Hash)
            v.each do |ki,vi|
              v[ki]="%0.2f MB" % (vi.to_f/1024**2)
            end
            r[k] = v
          else
            r[k]="%0.2f MB" % (v.to_f/1024**2)
          end
        else
          r[k]=v
        end
      end
      r
    end

    def server_status
      Magent.database.command(:serverStatus => 1)
    end

    def humanize(v, quote = false)
      if v.nil? && quote
        "null"
      elsif v.kind_of?(Hash)
        JSON.pretty_generate(v)
      elsif v.kind_of?(Array)
        v.map{|e| e.nil? ? "null" : e }.join("<br />")
      elsif v.kind_of?(Time)
        v.strftime("%d %B %Y %H:%M:%S").inspect
      elsif quote
        v.inspect
      else
        v
      end
    end

    def humanize_messages(messages)
      return "" if !messages.kind_of?(Array)

      messages.map do |e|
        name = e.first
        args = e.last.join(", ")
        "#{name}(#{args})"
      end.join(" -> ")
    end

    def channel_name_for(queue_id)
      queue_id.to_s.match("magent\.([^\.]+)")[1]
    end
  end
end
