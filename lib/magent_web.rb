require 'rubygems'

require 'json'
require 'magent'

require 'benchmark'
require 'sinatra'
require 'haml'
require 'yaml'

require 'net/http'
require 'uri'
require 'cgi'

require 'magent_web/mongo_helper'
require 'magent_web/app'

module MagentWeb
  def self.app
    MagentWeb::App
  end

  def self.connect
    return if Magent.database

    ENV["MAGENT_ENV"] ||= ENV["RACK_ENV"] || ENV["RAILS_ENV"]
    if !ENV["MAGENT_ENV"]
      raise ArgumentError, "please define the env var MAGENT_ENV"
    end

    if File.exist?("/etc/magent.yml")
      Magent.setup(YAML.load_file("/etc/magent.yml"), ENV["MAGENT_ENV"], {})
    elsif File.exist?("config/magent.yml")
      Magent.setup(YAML.load_file("config/magent.yml"), ENV["MAGENT_ENV"], {})
    elsif File.exist?("magent.yml")
      Magent.setup(YAML.load_file("magent.yml"), ENV["MAGENT_ENV"], {})
    else
      raise ArgumentError, "/etc/magent.yml, ./config/magent.yml or ./magent.yml were not found"
    end
  end
end

