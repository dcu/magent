$:.unshift File.expand_path("../lib", __FILE__)
require 'magent_web'

run MagentWeb.app

