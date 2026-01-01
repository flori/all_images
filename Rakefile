# vim: set filetype=ruby et sw=2 ts=2:

require 'gem_hadar'

GemHadar do
  name        'all_images'
  author      'Florian Frank'
  email       'flori@ping.de'
  homepage    "https://github.com/flori/#{name}"
  summary     'Runs a script in all of the docker images'
  description 'A script that runs a script in all of the configured docker images'
  test_dir    'spec'
  readme      'README.md'
  title       "#{name.camelize} -- #{summary}"
  licenses << 'MIT'
  executables << 'all_images'
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage',
    '.AppleDouble', 'tags', '.DS_Store', '.yardoc'
  package_ignore '.all_images.yml', '.gitignore', 'VERSION'

  changelog do
    filename 'CHANGES.md'
  end

  dependency  'tins',           '~> 1'
  dependency  'search_ui',      '~> 0.0'
  dependency  'term-ansicolor', '~> 1.11'
  dependency  'yaml'
  dependency  'fileutils'
  dependency  'shellwords'
  development_dependency 'rake'
  development_dependency 'simplecov'
  development_dependency 'rspec'
  development_dependency 'debug'
end
