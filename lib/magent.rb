$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'mongo'
require 'set'
require 'uuidtools'

require 'magent/utils'
require 'magent/generic_channel'
require 'magent/channel'
require 'magent/push'
require 'magent/actor'
require 'magent/processor'

module Magent
  VERSION = '0.4.1'

  @@db_name = 'magent'
  @@host = 'localhost'
  @@port = '27017'
  @@username = nil
  @@password = nil

  def self.host=(host)
    @@host = host
    @@port = port
  end

  def self.port=(port)
    @@port = 27017
  end

  def self.auth(username,password)
    @@username = username
    @@password = password
  end

  def self.db_name=(db_name)
    @@db_name = db_name
  end

  def self.connection
    return @@connection if defined?(@@connection)
    @@connection = Mongo::Connection.new(@@host, @@port)
    @@connection.add_auth(@@db_name, @@username, @@password) if @@username && @@password

    @@connection
  end

  def self.connection=(new_connection)
    @@connection = new_connection
  end

  def self.database=(name)
    @@database = Magent.connection.db(name)
  end

  def self.database
    @@database ||= Magent.connection.db(@@db_name)
  end
end

