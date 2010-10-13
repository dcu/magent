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
#         Processor.find(id).async(:my_queue).process.commit!
#     chained methods:
#         Processor.async(:my_queue, true).find(1).process.commit!
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

      def initialize(queue, target, priority = 3, test = false)
        @queue = queue
        @method_chain = []
        @target = target
        @test = test
        @priority = priority

        @channel = Magent::AsyncChannel.new(@queue)
      end

      def commit!
        @channel.push(@target, @method_chain, @priority)

        if @test
          target = @target
          @method_chain.each do |c|
            target = target.send(c[0], *c[1])
          end

          target
        end
      end

      def method_missing(m, *args, &blk)
        raise ArgumentError, "ruby blocks are not supported yet" if !blk.nil?
        @method_chain << [m, args]
        self
      end
    end

    module Methods
      # @question.async(:judge).on_view_question.commit!
      def async(queue = :default, priority = 3, test = false)
        Magent::Async::Proxy.new(queue, self, priority, test)
      end
    end
  end # Async
end
