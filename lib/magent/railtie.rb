require 'magent'
require 'rails'

module MyPlugin
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/magent.rake"
    end
  end
end
