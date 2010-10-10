module Magent
  class WebSocketChannel < Magent::GenericChannel
    def self.push(message)

      self.instance.enqueue(message)

      self.instance
    end

    def self.next_message
      self.instance.next_message
    end

    def self.instance
      @channel ||= self.new("magent.websocket")
    end
  end
end
