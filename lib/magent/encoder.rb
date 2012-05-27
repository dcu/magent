module Magent
  class Encoder
    def self.encode_arg(arg)
      if arg.kind_of?(Array)
        self.encode_args(arg)
      elsif arg.kind_of?(Hash)
        ret = {}
        arg.each do |k,v|
          ret[self.encode_arg(k)] = self.encode_arg(v)
        end
        ret
      elsif arg.class.respond_to?(:find) && arg.respond_to?(:id)
        ":F:#{arg.class}##{self.encode_arg(arg.id)}"
      elsif arg.kind_of?(Class)
        ":C:#{arg}"
      elsif arg.kind_of?(Symbol)
        ":S:#{arg}"
      elsif (BSON::BSON_RUBY.new.bson_type(arg) rescue false) # supported by bson
        arg
      else
        ":M:#{Marshal.dump(arg)}"
      end
    end

    def self.encode_args(args)
      args.map do |arg|
        self.encode_arg(arg)
      end
    end

    def self.decode_arg(arg)
      if arg.kind_of?(String)
        case arg[0,3]
        when ':F:'
          klass, id = arg[3..-1].split("#",2)
          Object.module_eval(klass).find(self.decode_arg(id))
        when ':C:'
          Object.module_eval(arg[3..-1])
        when ':S:'
          arg[3..-1].to_sym
        when ':M:'
          Marshal.load(arg[3..-1])
        else
          arg
        end
      elsif arg.kind_of?(Array)
        decode_args(arg)
      elsif arg.kind_of?(Hash)
        ret = {}
        arg.each do |k, v|
          ret[self.decode_arg(k)] = self.decode_arg(v)
        end
        ret
      else
        arg
      end
    end

    def self.decode_args(args)
      args.map do |arg|
        self.decode_arg(arg)
      end
    end
  end
end
