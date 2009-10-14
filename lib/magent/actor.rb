module Magent
  module Actor
    def self.included(klass)
      klass.class_eval do
        extend Actor::ClassMethods
        include Actor::InstanceMethods
      end
    end

    module ClassMethods
      def expose(*methods)
        methods.each do |m|
          actions << m.to_s
        end
      end

      def channel_name(name = nil)
        @channel_name ||= (name || Magent::Utils.underscore(self.name))
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
          channel_name = "/"+self.channel_name
          Channel.new(channel_name)
        end
      end

      def tasks
        @tasks ||= []
      end

      def at_least_every(seconds, &block)
        tasks << {:every => seconds, :last_time => Time.now, :block => block}
      end
    end

    module InstanceMethods
      def _run_tasks
        tasks = self.class.tasks

        return false if tasks.empty?
        performed = false

        tasks.each do |task|
          delta = Time.now - task[:last_time]

          if delta >= task[:every]
            task[:last_time] = Time.now
            instance_eval(&task[:block])
            performed = true
          end
        end

        performed
      end
    end
  end # Actor

  def self.register(actor)
    @current_actor = actor
  end

  def self.current_actor
    @current_actor
  end
end
