module MagentWeb
  module MongoHelper
    def queues
      q = []
      Magent.database.collections.each do |collection|
        if collection.name =~ /^magent\./ && collection.name !~ /errors$/
          q << collection
        end
      end

      q
    end
  end
end
