module Magent
  class AsyncChannel < GenericChannel
    def push(target, method, priority)
      encode_args(method[1])

      if target.kind_of?(Class)
        enqueue([target.to_s, nil, method], priority)
      elsif target.class.respond_to?(:find) && target.respond_to?(:id)
        enqueue([target.class.to_s, target.id, method], priority)
      else
        raise ArgumentError, "I don't know how to handle #{target.inspect}"
      end
    end

    def process!(message)
      klass, id, method = message

      return false if method.nil?

      target = async_find(klass, id)
      args = resolve_args(method[1])

      target = target.send(method[0], *args)

      true
    end

    private
  end # AsyncChannel
end
