# -*- encoding: utf-8 -*-
# stub: all_images 0.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "all_images".freeze
  s.version = "0.4.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "2024-08-08"
  s.description = "A script that runs a script in all of the configured docker images".freeze
  s.email = "flori@ping.de".freeze
  s.executables = ["all_images".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/all_images.rb".freeze, "lib/all_images/app.rb".freeze, "lib/all_images/config.rb".freeze, "lib/all_images/version.rb".freeze]
  s.files = [".utilsrc".freeze, "Gemfile".freeze, "LICENSE".freeze, "README.md".freeze, "Rakefile".freeze, "all_images.gemspec".freeze, "bin/all_images".freeze, "lib/all_images.rb".freeze, "lib/all_images/app.rb".freeze, "lib/all_images/config.rb".freeze, "lib/all_images/version.rb".freeze, "spec/app_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://github.com/flori/all_images".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--title".freeze, "AllImages -- Runs a script in all of the docker images".freeze, "--main".freeze, "README.md".freeze]
  s.rubygems_version = "3.5.16".freeze
  s.summary = "Runs a script in all of the docker images".freeze
  s.test_files = ["spec/app_spec.rb".freeze, "spec/spec_helper.rb".freeze]

  s.specification_version = 4

  s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.16.1".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<debug>.freeze, [">= 0".freeze])
  s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.0".freeze])
  s.add_runtime_dependency(%q<term-ansicolor>.freeze, [">= 0".freeze])
end
