# Example
#     class Processor
#       include Magent::Async
#       [..snip..]
#
#       def process
#         puts "Processing #{@params}"
#       end
#     end
#
#     async call:
#         Processor.find(id).async(:my_queue, priority).process
#     chained methods:
#         Processor.async(:my_queue, priority).find(1).process
#

module Magent
  module Async
    def self.included(base)
      base.class_eval do
        include Methods
        extend Methods
      end
    end

    class Proxy
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|proxy_|^object_id$)/ }

      def initialize(queue, target, priority = 3)
        @queue = queue
        @target = target
        @priority = priority

        @channel = Magent::AsyncChannel.new(@queue)
      end

      def commit!(method_name, args)
        if Magent.sync_mode
          @target.send(method_name, *args)
        else
          @channel.push(@target, [method_name, args], @priority)
        end

        @target
      end

      def method_missing(m, *args, &blk)
        raise ArgumentError, "ruby blocks are not supported yet" if !blk.nil?

        commit!(m, args)
      end
    end

    module Methods
      # @question.async(:judge).on_view_question
      def async(queue = :default, priority = 3)
        Magent::Async::Proxy.new(queue, self, priority)
      end
    end
  end # Async
end
