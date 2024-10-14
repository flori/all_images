require 'term/ansicolor'
require 'tmpdir'
require 'fileutils'
require 'tins'
require 'shellwords'

class AllImages::App
  include Term::ANSIColor
  include FileUtils

  def initialize(args)
    @args     = args.dup
    @command  = pick_command
    @commands = %w[ ls help run debug run_all ].sort
    @suffix   = Tins::Token.new(alphabet: Tins::Token::BASE32_ALPHABET, bits: 32)
  end

  def run
    @config   = load_config or return 23

    result = 0
    case @command
    when 'ls'
      puts Array(@config['images']).map(&:first)
    when 'help'
      puts "Usage: #{File.basename($0)} #{@commands * ?|} [IMAGE]"
    else
      Array(@config['images']).each do |image, script|
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

  def sh(*a)
    system(*a)
    if $?.success?
      true
    else
      raise "Command #{Shellwords.join(a).inspect} failed with: #{$?.exitstatus}"
    end
  end

  def name
    [ 'all_images', @suffix ] * ?-
  end

  def run_image(image, script, interactive: false)
    dockerfile = @config.fetch('dockerfile').to_s
    tag = provide_image image, dockerfile, script
    term = ENV.key?('TERM') ? %{ -e TERM=#{ENV['TERM'].inspect} } : ' '
    if interactive
      puts "You can run /script interactively now."
      sh "docker run --name #{name} -it #{term}-v `pwd`:/work '#{tag}' sh"
      return 0
    else
      if sh "docker run --name #{name} -it #{term}-v `pwd`:/work '#{tag}' sh -c /script"
        puts green('SUCCESS')
        return 0
      else
        puts red('FAILURE')
        return 1
      end
    end
  ensure
    sh "docker rm -f #{name} >/dev/null"
  end

  def pick_command
    case command = @args.shift
    when 'run_all', nil
      'run_all'
    when 'ls'
      'ls'
    when 'run'
      @selected = @args.shift or fail "Usage: #{File.basename($0)} #{command} IMAGE"
      'run_selected'
    when 'debug'
      @selected = @args.shift or fail "Usage: #{File.basename($0)} #{command} IMAGE"
      'debug_selected'
    else
      'help'
    end
  end

  def load_config
    config_filename = '.all_images.yml'
    if @args.empty?
      unless File.exist?(config_filename)
        AllImages::Config.init(config_filename)
        puts bold("Config file #{config_filename} not found!\n\n")  +
          "The following example was created, adapt to your own needs:\n\n",
          AllImages::Config.example, ""
        return
      end
    else
      config_filename = @args.shift
    end
    AllImages::Config.load(config_filename)
  end

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
      sh "docker build --pull -t '#{tag}' ."
    end
    tag
  ensure
    rm_rf File.join(Dir.tmpdir, 'build')
  end
end
