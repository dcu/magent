module Magent
  class WebSocketChannel < Magent::GenericChannel
    def self.push(message)
      self.instance.enqueue(message)
      self.instance
    end

    def self.dequeue
      self.instance.dequeue
    end

    def self.instance
      @channel ||= self.new(Magent.config["websocket_channel"]||"magent.websocket")
    end
  end
end
