# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{magent}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Cuadrado"]
  s.date = %q{2009-10-11}
  s.default_executable = %q{magent}
  s.description = %q{Simple job queue system based on mongodb}
  s.email = ["krawek@gmail.com"]
  s.executables = ["magent"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "bin/magent", "examples/simple/bot.rb", "lib/magent.rb", "lib/magent/actor.rb", "lib/magent/channel.rb", "lib/magent/processor.rb", "lib/magent/push.rb", "lib/magent/utils.rb", "magent.gemspec", "script/console", "test/test_helper.rb", "test/test_magent.rb"]
  s.homepage = %q{http://github.com/dcu/magent}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{magent}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Simple job queue system based on mongodb}
  s.test_files = ["test/test_helper.rb", "test/test_magent.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongodb-mongo>, [">= 0.14"])
      s.add_development_dependency(%q<hoe>, [">= 2.3.3"])
    else
      s.add_dependency(%q<mongodb-mongo>, [">= 0.14"])
      s.add_dependency(%q<hoe>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<mongodb-mongo>, [">= 0.14"])
    s.add_dependency(%q<hoe>, [">= 2.3.3"])
  end
end
