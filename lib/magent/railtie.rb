require 'magent'
require 'rails'

module Magent
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/magent.rake"
    end
  end
end
