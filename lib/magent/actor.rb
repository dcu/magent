module Magent
  module Actor
    def self.included(klass)
      klass.class_eval do
        extend Actor::ClassMethods
      end
    end

    module ClassMethods
      def expose(*actions)
        @actions ||= Set.new

        actions.each do |m|
          @actions << m.to_s
        end
      end

      def can_handle?(action)
        return false if @actions.nil?
        @actions.include?(action.to_s)
      end
    end
  end
end
