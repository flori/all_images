require 'term/ansicolor'
require 'tmpdir'
require 'fileutils'

class AllImages::App
  include Term::ANSIColor
  include FileUtils

  alias sh system

  def initialize(args)
    @args = args.dup
  end

  def run
    result     = 0
    @config    = load_config or return 23
    dockerfile = @config.fetch('dockerfile').to_s

    Array(@config['images']).each do |image, script|
      tag = provide_image image, dockerfile
      if sh "docker run --name all_images -v `pwd`:/work '#{tag}' sh -c '#{script}'"
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
    result
  end

  private

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
