module Magent
  def self.enqueue(channel_name, method, *args)
    self.channel(channel_name.to_s).enqueue(method, args)
  end

  def self.channel(name)
    self.channels[name] ||= Channel.new(name)
  end

  def self.channels
    @channels ||= {}
  end
end
