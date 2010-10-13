$:.unshift File.dirname(__FILE__)+"/../../lib/"
require 'rubygems'
require 'magent'
require 'mongo_mapper'


MongoMapper.database = "test"
Magent.database = "test"

class Thing
  include MongoMapper::Document
  include Magent::Async

  key :_id, String
  key :name

  def process_something(arg)
    puts "Processing: #{arg}"
  end

  def process_nothing
    puts "Processing..."
  end

  def self.foo
    puts "MAX PRIORITY"
  end
end


thing = Thing.create(:_id => "foo")

# 3 messages
thing.async.process_something("testing").commit!
thing.async.process_nothing.commit!
Thing.async.find(thing.id).process_something("testing2").commit!
Thing.async.foo.commit!(1)

Magent::Processor.new(Magent::AsyncChannel.new(:default)).run!


