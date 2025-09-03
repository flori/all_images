require 'yaml'

# Configuration handling for AllImages
#
# Provides functionality for loading, initializing, and accessing example
# configuration files used by the AllImages application to define Docker image
# build and execution parameters.
module AllImages::Config
  # Loads and parses a YAML configuration file
  #
  # @param filename [ String ] the path to the YAML file to load
  #
  # @return [ Object ] the parsed YAML content as a Ruby object
  def load(filename)
    YAML.unsafe_load_file(filename)
  end

  # Example configuration for `all_images`.
  EXAMPLE = <<~EOT
    dockerfile: |-
      RUN apk add --no-cache build-base yaml-dev git
      RUN gem install gem_hadar

    script: &script |-
      echo -e "\\e[1m"
      ruby -v
      bundle
      echo -e "\\e[0m"
      rake test

    images:
      ruby:3.4-alpine: *script
      ruby:3.3-alpine: *script
      ruby:3.2-alpine: *script
  EOT

  # Initializes a configuration file with example content
  #
  # Creates a new configuration file at the specified path and writes example
  # configuration content to it. This method is typically used when no existing
  # configuration file is found, providing a starting point for users to
  # customize.
  #
  # @param filename [ String ] the path where the example configuration file
  # will be created
  def init(filename)
    File.open(filename, ?w) do |output|
      output.print EXAMPLE
    end
  end

  # Returns the example configuration content
  #
  # This method provides access to the predefined example configuration
  # that can be used to initialize a new configuration file.
  #
  # @return [ String ] the multi-line string containing the example configuration
  #                     structure and default settings
  def example
    EXAMPLE
  end

  extend self
end
