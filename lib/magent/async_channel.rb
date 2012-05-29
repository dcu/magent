module Magent
  class AsyncChannel < GenericChannel
    def push(target, method, priority, locale)
      method[1] = Magent::Encoder.encode_args(method[1])
      enqueue([Magent::Encoder.encode_arg(target), method, locale], priority)
    end

    def process!(message)
      target, method, locale = message
      return false if method.nil?

      prev_locale = nil
      if locale && defined?(I18n)
        prev_locale = I18n.locale
        I18n.locale = locale
      end

      target = Magent::Encoder.decode_arg(target)
      args = Magent::Encoder.decode_args(method[1])

      puts "### Processing #{target.inspect}.#{method[0]}(#{args.map{|e| e.inspect }.join(",") })"

      target.send(method[0], *args)

      if prev_locale
        I18n.locale = prev_locale
      end

      true
    end

    private
  end # AsyncChannel
end
