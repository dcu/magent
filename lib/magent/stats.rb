module Magent
  module Stats
    def stats_collection
      @stats_collection ||= Magent.database.collection("magent.stats")
    end

    def stats
      @stats ||= if doc = stats_collection.find({:_id => @name}, {}).next_document
        doc
      else
        stats_collection.save({:_id => @name,
                               :created_at => Time.now.utc,
                               :total_errors => 0,
                               :total_jobs => 0,
                               :last_processed_job => {"duration" => 0, "method" => "", "priority" => 0},
                               :updated_at => Time.now.utc,
                               :updated_by => "",
                               :workers => {}
                              }, {:safe => true})

        stats_collection.find({:_id => @name}, {}).next_document
      end
    end

    def on_job_processed(last_job, duration, updated_by)
      last_job["duration"] = ("%f" % duration)
      updated_at = Time.now

      updates = {}
      updates[:$inc] = {:total_jobs => 1, :"workers.#{updated_by}.total_jobs" => 1}
      updates[:$set] = {:updated_at => updated_at, :updated_by => updated_by,
                        :last_processed_job => last_job,
                        :"workers.#{updated_by}.last_update_at" => updated_at }

      stats_collection.update({:_id => @name}, updates, {:multi => true})
    end

    def on_job_failed(updated_by)
      stats_collection.update({:_id => @name}, {:$inc => {:total_errors => 1, :"workers.#{updated_by}.total_errors" => 1} })
    end

    def on_start(updated_by)
      puts ">>> Starting magent with stats:"
      stats.each do |k, v|
        title = k.split("_"); title.delete("")
        title = title.map{|w| w.strip.upcase}.join(" ")+":"

        value = v.inspect
        if v.kind_of?(Hash)
          value = ""
          v.each do |kk, vv|
            value << "\n"
          end
        end

        puts "#{title.ljust(20, " ")} #{v}"
      end

      stats_collection.update({:_id => @name}, {:$set => {:"workers.#{updated_by}.last_update_at" => Time.now.utc},
                                                :$inc => {:"workers.#{updated_by}.total_restarts" => 1} }, {:safe => true, :multi => true})
    end

    def on_quit(updated_by)
      stats_collection.update({:_id => @name}, {:set => {:"workers.#{updated_by}.quitted_at" => Time.now.utc} })
    end
  end
end