# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{magent}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David A. Cuadrado"]
  s.date = %q{2010-10-10}
  s.default_executable = %q{magent}
  s.description = %q{Simple job queue system based on mongodb}
  s.email = %q{krawek@gmail.com}
  s.executables = ["magent"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "Gemfile",
     "Gemfile.lock",
     "History.txt",
     "LICENSE",
     "Manifest.txt",
     "PostInstall.txt",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/magent",
     "examples/comm/run.rb",
     "examples/comm/worker.rb",
     "examples/error/error.rb",
     "examples/simple/bot.rb",
     "examples/stats/stats.rb",
     "lib/magent.rb",
     "lib/magent/actor.rb",
     "lib/magent/channel.rb",
     "lib/magent/generic_channel.rb",
     "lib/magent/processor.rb",
     "lib/magent/push.rb",
     "lib/magent/utils.rb",
     "lib/magent/web_socket_server.rb",
     "magent.gemspec",
     "script/console",
     "test/test_helper.rb",
     "test/test_magent.rb"
  ]
  s.homepage = %q{http://github.com/dcu/magent}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Simple job queue system based on mongodb}
  s.test_files = [
    "test/test_helper.rb",
     "test/test_magent.rb",
     "examples/simple/bot.rb",
     "examples/error/error.rb",
     "examples/comm/run.rb",
     "examples/comm/worker.rb",
     "examples/stats/stats.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_runtime_dependency(%q<mongo>, [">= 0"])
      s.add_runtime_dependency(%q<em-websocket>, [">= 0"])
      s.add_runtime_dependency(%q<uuidtools>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<mongo>, [">= 0"])
      s.add_dependency(%q<em-websocket>, [">= 0"])
      s.add_dependency(%q<uuidtools>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<mongo>, [">= 0"])
    s.add_dependency(%q<em-websocket>, [">= 0"])
    s.add_dependency(%q<uuidtools>, [">= 0"])
  end
end

