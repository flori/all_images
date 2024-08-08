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
  ignore      '.*.sw[pon]', 'pkg', 'Gemfile.lock', 'coverage',
    '.AppleDouble', 'tags', '.DS_Store'
  readme      'README.md'
  title       "#{name.camelize} -- #{summary}"
  package_ignore '.all_images.yml', '.gitignore', 'VERSION'

  dependency  'tins', '~>1.0'
  dependency  'term-ansicolor'
  development_dependency 'rake'
  development_dependency 'simplecov'
  development_dependency 'rspec'
  development_dependency 'debug'
  licenses << 'MIT'
  executables << 'all_images'
end
