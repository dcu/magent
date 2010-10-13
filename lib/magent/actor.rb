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
        @channel_name ||= (name || Magent::Utils.underscore(self.name)).to_s
      end

      def actions
        @actions ||= Set.new
      end

      def can_handle?(action)
        actions.include?(action.to_s)
      end

      def channel
        @channel ||= begin
          ActorChannel.new(self.channel_name)
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
            begin
              instance_eval(&task[:block])
            rescue Exception => e
              $stderr.puts "Failed periodical task: #{e.message}"
              $stderr.puts e.backtrace.join("\n\t")
            end
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

  def self.current_channel
    self.current_actor.channel
  end
end
