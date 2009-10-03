module Magent
  module Actor
    def self.included(klass)
      klass.class_eval do
        extend Actor::ClassMethods
      end
    end

    module ClassMethods
      def expose(*methods)
        methods.each do |m|
          actions << m.to_s
        end
      end

      def actions
        @actions ||= Set.new
      end

      def can_handle?(action)
        return false if @actions.nil?
        @actions.include?(action.to_s)
      end

      def channel
        @channel ||= begin
          channel_name = "/"+Magent::Utils.underscore(self.name)
          Channel.new(channel_name)
        end
      end
    end
  end
end
