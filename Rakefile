require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/magent'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'magent' do
  self.developer 'David Cuadrado', 'krawek@gmail.com'
  self.post_install_message = ''
  self.rubyforge_name       = self.name
  self.extra_deps         = [['mongo','>= 0.18.2'],
                             ['uuidtools', '>= 2.0.0']]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]

