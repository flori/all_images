require 'term/ansicolor'
require 'tmpdir'
require 'fileutils'
require 'tins'
require 'tins/xt/full'
require 'shellwords'
require 'search_ui'

# AllImages::App is the core application class that orchestrates Docker image
# execution workflows
#
# This class provides the main interface for running scripts across multiple
# Docker images, handling configuration loading, command processing, and Docker
# container operations.
#
# It supports various commands including listing available images, running all
# images, running specific images, and debugging interactive sessions.
#
# The application manages Docker image building, tagging, and cleanup while
# providing environment variable handling and error reporting capabilities.
class AllImages::App
  include Term::ANSIColor
  include FileUtils
  include SearchUI

  # Initializes a new instance of the AllImages application
  #
  # Sets up the application with the provided command-line arguments,
  # determines the initial command to execute, and prepares internal state
  # for processing configuration and Docker image operations.
  #
  # @param args [ Array<String> ] the command-line arguments passed to the
  # application
  def initialize(args)
    @args     = args.dup
    @config   = load_config or return 23
    @command  = pick_command
    @commands = %w[ ls help run debug run_all ].sort
    @suffix   = Tins::Token.new(alphabet: Tins::Token::BASE32_ALPHABET, bits: 32)
  end

  # Executes the configured command across Docker images
  #
  # Processes the specified command and runs it against the configured Docker
  # images. Depending on the command, this method may list available images,
  # display help information, or execute scripts in containers. It handles both
  # individual image execution and batch processing of all configured images.
  #
  # @return [ Integer ] the cumulative result code from executing commands
  # across images, where 0 indicates success and non-zero values indicate
  # failures
  def run
    result  = 0
    case @command
    when 'ls'
      puts images.map(&:first)
    when 'help'
      puts "Usage: #{File.basename($0)} #{@commands * ?|} [IMAGE]"
    else
      images.each do |image, script|
        case @command
        when 'run_all'
          result |= run_image(image, script)
        when 'run_selected'
          image == @selected and result |= run_image(image, script)
        when 'debug_selected'
          image == @selected and result |= run_image(image, script, interactive: true)
        end
        if @config['fail_fast'] && result != 0
          return 1
        end
      end
    end
    result
  end

  private

  # Returns an array of configured Docker images for execution
  #
  # This method retrieves the list of Docker images from the application's
  # configuration and ensures it is returned as an Array instance, even if the
  # configuration contains a single image value rather than an array.
  #
  # @return [ Array<String> ] an array containing the names of Docker images
  #                           to be processed by the application
  def images
    Array(@config&.[]('images'))
  end

  # Prints the given text using green colored output
  #
  # @param text [ String ] the text to be printed with color formatting
  def info_puts(text)
    puts white { on_color(28) { text } }
  end

  # Returns a hash of environment variables for Docker container execution
  #
  # This method constructs a set of environment variables by combining those
  # specified in the configuration file with any terminal-related variables
  # from the current environment, ensuring proper variable expansion and
  # assignment for use in Docker container runs.
  #
  # @return [ Hash ] a hash mapping environment variable names to their values
  def env
    vars = @config.fetch('env', [])
    vars << 'TERM' if ENV.key?('TERM')
    vars.each_with_object({}) { |v, h|
      name, value = v.split(?=, 2)
      if value
        h[name] = value
      else
        h[name] = ENV[name]
      end
    }
  end

  def sh(script, crash: true)
    if $DEBUG
      STDERR.puts "Executing #{a.inspect}."
    end
    system(script)
    if $?.success?
      true
    elsif crash
      raise "Command #{script.inspect} failed with: #{$?.exitstatus}"
    end
  end

  # Generates a unique name for Docker container operations
  #
  # Creates a name by combining the fixed prefix "all_images" with a randomly
  # generated suffix, separated by a hyphen, for use in Docker container
  # identification and cleanup.
  #
  # @return [ String ] a unique identifier suitable for Docker container naming
  def name
    [ 'all_images', @suffix ] * ?-
  end

  # Executes a Docker image with the specified script in a container
  #
  # This method builds a Docker image based on the provided configuration,
  # runs the script inside the container, and handles both interactive and
  # non-interactive execution modes. It ensures cleanup of the container
  # afterward regardless of success or failure.
  #
  # @param image [ String ] the Docker image name to use for execution
  # @param script [ String ] the script content to be executed within the container
  # @param interactive [ TrueClass, FalseClass ] flag indicating whether to run
  #   the container interactively or in non-interactive mode
  #
  # @return [ Integer ] exit code indicating success (0) or failure (1) of the script execution
  def run_image(image, script, interactive: false)
    if before = @config['before']
      sh before
    end
    dockerfile = @config.fetch('dockerfile').to_s
    tag        = provide_image image, dockerfile, script
    envs       = env.full? { |e| +' ' << e.map { |n, v| '-e %s=%s' % [ n, v.inspect ] } * ' ' }
    result     = 1
    if interactive
      puts "You can run /script interactively now."
      sh "docker run --name #{name} -it#{envs} -v `pwd`:/work '#{tag}' sh", crash: true
      result = nil
    else
      info_puts "Running container #{name.inspect} for image tagged #{tag.inspect}."
      if sh "docker run --name #{name} -it#{envs} -v `pwd`:/work '#{tag}' sh -c /script", crash: false
        info_puts "Image tagged #{tag.inspect} was run with result:"
        puts green('SUCCESS')
        result = 0
      else
        info_puts "Image tagged #{tag.inspect} was run with result:"
        puts red('FAILURE')
      end
    end
    if result and after = @config['after']
      ENV['RESULT'] = result.to_s
      sh after, crash: false
    end
    result.to_i
  ensure
    sh "docker rm -f #{name} >/dev/null"
  end

  # Presents a searchable interface for selecting a configured Docker image
  #
  # This method initializes and starts a search UI that allows users to
  # interactively pick a Docker image from the list of configured images. It
  # provides filtering capabilities based on user input and displays the
  # options with visual highlighting for the selected item.
  #
  # @return [ String ] the name of the selected Docker image
  def pick_configured_image
    Search.new(
      prompt: 'Pick a configured container image: ',
      match: -> answer {
        image_names = images.map(&:first)
        matches = image_names.grep(/#{Regexp.quote(answer)}/)
        matches.empty? and matches = image_names
        matches.first(Tins::Terminal.lines - 1)
      },
      query: -> _answer, matches, selector {
        matches.each_with_index.map { |m, i|
          i == selector ? "#{blue{?⮕}} #{on_blue{bold{m}}}" : "  #{m.to_s}"
        } * ?\n
      },
      found: -> _answer, matches, selector {
        matches[selector]
      },
      output: STDOUT
    ).start
  end

  # Determines the command to execute based on the provided arguments
  #
  # Processes the command-line arguments to identify the intended operation,
  # handling cases for running all images, listing images, running a specific
  # image, debugging a specific image, or displaying help information.
  #
  # @return [ String ] the determined command to be executed
  def pick_command
    case command = @args.shift
    when 'run_all', nil
      'run_all'
    when 'ls'
      'ls'
    when 'run'
      @selected = @args.shift || pick_configured_image
      @selected or fail "Usage: #{File.basename($0)} #{command} IMAGE"
      'run_selected'
    when 'debug'
      @selected = @args.shift || pick_configured_image
      @selected or fail "Usage: #{File.basename($0)} #{command} IMAGE"
      'debug_selected'
    else
      'help'
    end
  end

  # Loads and processes the configuration file for the AllImages application
  #
  # This method determines the appropriate configuration file to load based on
  # command-line arguments or defaults to .all_images.yml. If the file doesn't exist
  # and no alternative is provided, it initializes a default configuration file
  # and displays an example for customization before exiting.
  #
  # @return [ Object, nil ] the parsed configuration hash if successful, or nil if
  #   initialization occurred and the method should terminate early
  def load_config
    config_filename = '.all_images.yml'
    unless File.exist?(config_filename)
      AllImages::Config.init(config_filename)
      puts bold("Config file #{config_filename} not found!\n\n")  +
        "The following example was created, adapt to your own needs:\n\n",
        AllImages::Config.example, ""
      return
    end
    AllImages::Config.load(config_filename)
  end

  # Prepares a Docker image for execution by pulling, building, and tagging it
  #
  # This method ensures that the specified Docker image is available locally,
  # creates a temporary build environment, generates a Dockerfile with the
  # provided configuration and script, builds the image with a unique tag, and
  # cleans up the temporary files afterward.
  #
  # @param image [ String ] the base Docker image name to pull and use for building
  # @param dockerfile [ String ] additional Dockerfile instructions to include in the build
  # @param script [ String ] the script content that will be copied into the built image
  #
  # @return [ String ] the unique tag assigned to the newly built Docker image
  def provide_image(image, dockerfile, script)
    prefix = @config.fetch('prefix', File.basename(Dir.pwd))
    tag    = "#{prefix}/all_images/#{image}"
    sh "docker pull '#{image}'"
    build_dir = File.join(Dir.tmpdir, 'build')
    mkdir_p build_dir
    cd build_dir do
      File.open('script', ?w) do |s|
        s.print script
      end
      File.open('Dockerfile', ?w) do |t|
        t.puts <<~end
        FROM #{image}

        WORKDIR /work

        #{dockerfile}

        COPY --chmod=755 script /script
      end
      end
      info_puts "Now building image #{tag.inspect}…"
      sh "docker build --pull -t '#{tag}' ."
    end
    tag
  ensure
    rm_rf File.join(Dir.tmpdir, 'build')
  end
end
