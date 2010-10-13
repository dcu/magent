module Magent
  class AsyncChannel < GenericChannel
    def push(target, method_chain, priority)
      if target.kind_of?(Class)
        enqueue([target.to_s, nil, method_chain], priority)
      elsif target.class.respond_to?(:find) && target.respond_to?(:id)
        enqueue([target.class.to_s, target.id, method_chain], priority)
      else
        raise ArgumentError, "I don't know how to handle #{target.inspect}"
      end
    end

    def process!
      klass, id, method_chain = self.dequeue

      return false if method_chain.nil?

      target = resolve_target(klass, id)

      method_chain.each do |c|
        puts "#{target.inspect} -> #{c.inspect}"
        target = target.send(c[0], *c[1])
      end

      true
    end

    private
    def resolve_target(klass, id)
      klass = Object.module_eval(klass) if klass.kind_of?(String)

      if id
        klass.find(id)
      else
        klass
      end
    end
  end # AsyncChannel
end
