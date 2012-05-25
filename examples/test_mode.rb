#!/usr/bin/env ruby

$:.unshift File.expand_path("../../lib", __FILE__)

require 'magent'

class MyClass
  include Magent::Async

  def foo
    puts "bar"
  end
end

Magent.sync_mode = true

c = MyClass.new
c.async.foo


