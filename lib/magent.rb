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

MongoMapper.setup(YAML.load_file(Rails.root.join('config', 'database.yml')),
                  Rails.env, { :logger => Rails.logger, :passenger => false })
module Magent
  @@database_name = "magent"

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
    @@database ||= Magent.connection.db(@@db_name)
  end

  def self.config
    raise(ArgumentError, 'Set config before connecting. MongoMapper.config = {...}') unless defined?(@@config)
    @@cconfig
  end

  def self.config=(config)
    @@config = hash
  end

  def self.connect(environment, options={})
    raise 'Set config before connecting. Magent.config = {...}' if config.blank?

    env = config_for_environment(environment)
    MongoMapper.connection = Mongo::Connection.new(env['host'], env['port'], options)
    MongoMapper.database = env['database']
    MongoMapper.database.authenticate(env['username'], env['password']) if env['username'] && env['password']
  end

  def self.setup(config, environment = nil, options = {})
    self.config = config
    connect(environment, options)
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

