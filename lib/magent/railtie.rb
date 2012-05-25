require 'magent'
require 'rails'

module Magent
  class Railtie < Rails::Railtie
    rake_tasks do
      load "magent/tasks.rb"
    end
  end
end
