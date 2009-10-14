$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'mongo'
require 'set'
require 'magent/utils'
require 'magent/channel'
require 'magent/push'
require 'magent/actor'
require 'magent/processor'

module Magent
  VERSION = '0.1.0'

  def self.connection
    @@connection ||= Mongo::Connection.new(nil, nil, :auto_reconnect => true)
  end

  def self.connection=(new_connection)
    @@connection = new_connection
  end

  def self.database=(name)
    @@database = Magent.connection.db(name)
  end

  def self.database
    @@database
  end
end

Magent.database = 'magent'

