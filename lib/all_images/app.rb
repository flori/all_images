require 'term/ansicolor'
require 'tmpdir'
require 'fileutils'

class AllImages::App
  include Term::ANSIColor
  include FileUtils

  alias sh system

  def initialize(args)
    @args = args.dup
    @command = determine_command
  end

  def run
    result     = 0
    @config    = load_config or return 23

    if @command == 'ls'
      puts Array(@config['images']).map(&:first)
    else
      Array(@config['images']).each do |image, script|
        case @command
        when 'run_all'
          run_image(image, script)
        when 'run_selected'
          image == @selected and run_image(image, script)
        when 'debug_selected'
          image == @selected and run_image(image, script, interactive: true)
        end
      end
    end
    result
  end

  private

  def run_image(image, script, interactive: false)
    dockerfile = @config.fetch('dockerfile').to_s
    tag = provide_image image, dockerfile
    it = interactive ? ' -it ' : ' '
    if sh "docker run --name all_images#{it}-v `pwd`:/work '#{tag}' sh -c '#{script}'"
      puts green('SUCCESS')
    else
      puts red('FAILURE')
      if @config['fail_fast']
        return 1
      else
        result |= 1
      end
    end
  ensure
    sh 'docker rm -f all_images >/dev/null'
  end

  def determine_command
    case command = @args.first
    when nil
      'run_all'
    when 'ls'
      @args.shift
      'ls'
    when 'run'
      @args.shift
      @selected = @args.shift or fail "Usage: #{File.basename($0)} #{command} IMAGE"
      'run_selected'
    when 'debug'
      @args.shift
      @selected = @args.shift or fail "Usage: #{File.basename($0)} #{command} IMAGE"
      'debug_selected'
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

  def provide_image(image, dockerfile)
    prefix = @config.fetch('prefix', File.basename(Dir.pwd))
    tag    = "#{prefix}/all_images/#{image}"
    sh "docker pull '#{image}'"
    build_dir = File.join(Dir.tmpdir, 'build')
    mkdir_p build_dir
    cd build_dir do
      File.open('Dockerfile', 'w') do |t|
        t.puts <<~end
        FROM #{image}

        WORKDIR /work

        #{dockerfile}
      end
      end
      sh "docker build --pull -t '#{tag}' ."
    end
    tag
  ensure
    rm_rf File.join(Dir.tmpdir, 'build')
  end
end
