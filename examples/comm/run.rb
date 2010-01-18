#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__)+"/../../lib/"
require 'magent'

id = "#{rand(16)}#{rand(16)}#{rand(16)}#{rand(16)}"

values = (1..5).to_a.map { rand(10) }
puts values.join(" + ")
Magent.push("workers", :sum, id, *values)

channel = Magent::GenericChannel.new("+#{id}")

loop do
  v = channel.dequeue;
  if v
    $stdout.puts v.inspect
    break
  end
  sleep 0.1
end

