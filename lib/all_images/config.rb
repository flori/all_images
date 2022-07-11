require 'yaml'

module AllImages::Config
  def load(filename)
    YAML.unsafe_load_file(filename)
  end

  EXAMPLE = <<~end
    dockerfile: |-
      RUN apk add --no-cache build-base git
      RUN gem update --system
      RUN gem install gem_hadar bundler

    script: &script |-
      echo -e "\\e[1m"
      ruby -v
      bundle
      echo -e "\\e[0m"
      rake test

    images:
      ruby:3.1-alpine: *script
      ruby:3.0-alpine: *script
      ruby:2.7-alpine: *script
      ruby:2.6-alpine: *script
      ruby:2.5-alpine: *script
  end

  def init(filename)
    File.open(filename, 'w') do |output|
      output.print EXAMPLE
    end
  end

  def example
    EXAMPLE
  end

  extend self
end
