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

module MagentWeb
  def self.app
    MagentWeb::App
  end

  def self.connect
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

  def self.config_path
    Dir.home+"/.magent_webrc"
  end

  def self.config
    @config ||= YAML.load_file(self.config_path)
  end
end

if !File.exist?(MagentWeb.config_path)
  File.open(MagentWeb.config_path, "w") do |f|
    f.write YAML.dump("username" => "admin", "password" => "admin", "enable_auth" => true)
  end

  $stdout.puts "Created #{MagentWeb.config_path} with username=admin password=admin"
end

require 'magent_web/mongo_helper'
require 'magent_web/app'
