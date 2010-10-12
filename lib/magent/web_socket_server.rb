require 'magent/web_socket_channel'
module Magent
  class WebSocketServer
    def initialize(options = {})
      options = {:host => "0.0.0.0", :port => 34567}.merge(options)

      $stdout.puts ">> Server running and up! #{options}}" if options[:debug]

      EventMachine.run do
        @channel = EM::Channel.new
        @channels = {}
        @channel_ids = {}
        @sids = {}

        EventMachine.add_periodic_timer(options.delete(:interval)||10) do
          while v = Magent::WebSocketChannel.next_message
            message = v["message"]
            if message && (channel = @channels[message["channel_id"]])
              channel.push(message.to_json)
            end
          end
        end

        EventMachine::WebSocket.start(options) do |ws|
          ws.onopen do
            ws.onmessage do |msg|
              data = JSON.parse(msg) rescue {}

              case data["id"]
              when 'start'
                if data["channel_id"].present? && (channel_id = validate_channel_id(data["channel_id"]))
                  key = generate_unique_key(data["key"])
                  @channels[channel_id] ||= EM::Channel.new
                  @channel_ids[key] = channel_id

                  sid = @channels[channel_id].subscribe { |msg| ws.send(msg) }

                  @sids[key] = sid
                  ws.onclose do
                    @channel_ids.delete(key)
                    @channels[channel_id].unsubscribe(sid)
                    @sids.delete(key)
                  end

                  ws.send({:id => "ack", :key => key}.to_json)
                else
                  ws.close_connection
                end
              when 'chatmessage'
                key = data["key"]
                return invalid_key if key.blank? || @sids[key].blank?

                channel_id = @channel_ids[key]

                if channel_id
                  @channels[channel_id].push({:id => 'chatmessage', :from => user_name(key, @sids[key]), :message => data["message"]}.to_json)
                else
                  ws.send({:id => 'announcement', :type => "error", :message => "cannot find the channel"}.to_json)
                end
              else
                handle_message(ws, data)
              end
            end
          end
        end # EM::WebSocket
      end
    end

    def self.start(options = {})
      self.new(options)
    end

    protected
    def invalid_key(ws)
      ws.send({:id => 'announcement', :type => "error", :message => "you must provide your unique key"}.to_json)
    end

    def handle_message(ws, data)
      ws.send({:id => 'announcement', :type => "error", :message => "unhandled message: #{data.inspect}"}.to_json)
    end

    protected
    def generate_unique_key(default = nil)
      default || UUIDTools::UUID.random_create.hexdigest
    end

    def validate_channel_id(id)
      return id if !id.blank?
    end

    def user_name(socket_key, sid)
      "Guest #{sid}"
    end
  end # Class
end