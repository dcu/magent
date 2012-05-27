module Magent
  class AsyncChannel < GenericChannel
    def push(target, method, priority)
      method[1] = Magent::Encoder.encode_args(method[1])
      enqueue([Magent::Encoder.encode_arg(target), method], priority)
    end

    def process!(message)
      target, method = message

      return false if method.nil?

      target = Magent::Encoder.decode_arg(target)
      args = Magent::Encoder.decode_args(method[1])

      puts "### Processing #{target.inspect}.#{method[0]}(#{args.map{|e| e.inspect }.join(",") })"

      target.send(method[0], *args)

      true
    end

    private
  end # AsyncChannel
end
