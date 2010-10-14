$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'mongo'
require 'set'
require 'uuidtools'

require 'magent/failure'

require 'magent/utils'
require 'magent/generic_channel'
require 'magent/actor_channel'
require 'magent/push'
require 'magent/actor'
require 'magent/processor'

require 'magent/async'
require 'magent/async_channel'

require 'magent/railtie' if defined?(Rails)

if defined?(EventMachine::WebSocket)
  require 'magent/web_socket_server'
end

module Magent
  @@database_name = "magent"

  @@config = {
    "host" => "0.0.0.0",
    "port" => 27017
  }

  def self.connection
    @@connection ||= Mongo::Connection.new
  end

  def self.logger
    connection.logger
  end

  def self.connection=(new_connection)
    @@connection = new_connection
  end

  def self.database=(name)
    @@database = nil
    @@database_name = name
  end

  def self.database
    @@database ||= Magent.connection.db(@@database_name)
  end

  def self.config
    @@config
  end

  def self.config=(config)
    @@config = config
  end

  def self.connect(environment, options={})
    raise 'Set config before connecting. Magent.config = {...}' if config.blank?

    env = config_for_environment(environment)
    Magent.connection = Mongo::Connection.new(env['host'], env['port'], options)
    Magent.database = env['database']
    Magent.database.authenticate(env['username'], env['password']) if env['username'] && env['password']
  end

  def self.setup(config, environment = nil, options = {})
    self.config = config
    connect(environment, options)
  end

  # deprecated
  def self.host=(host)
    @@config['host'] = host
  end

  def self.port=(port)
    @@config['port'] = port
  end

  def self.db_name=(db_name)
    @@database_name = db_name
  end

  def self.auth(username, passwd)
    @@config['username'] = username
    @@config['password'] = passwd
  end

  private
  def self.config_for_environment(environment)
    env = environment ? config[environment] : config

    return env if env['uri'].blank?

    uri = URI.parse(env['uri'])
    raise InvalidScheme.new('must be mongodb') unless uri.scheme == 'mongodb'

    {
      'host'     => uri.host,
      'port'     => uri.port,
      'database' => uri.path.gsub(/^\//, ''),
      'username' => uri.user,
      'password' => uri.password,
    }
  end
end

