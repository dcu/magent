class Agent
  include Magent::Async

  def self.enqueue_job(name, *args)
    async(:specs).send(name, *args)
  end

  def self.do_job(*args)
    puts ">> exec job with #{args.inspect}"
  end
end
