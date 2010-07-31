module PlugemsDeploy
  class Cli
        
  require 'optparse'
  require 'capistrano/cli'
  require 'plugems_deploy/capistrano'

  def self.execute!
    new.execute!
  end

  # The array of (unparsed) command-line options
  attr_reader :args

  # The hash of (parsed) command-line options
  attr_reader :options

  def initialize(args = ARGV)
    @args = args
    @options = { :version => '> 0.0', :deps_only => false, :debug => false }

    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options] ACTION ARGS"

      opts.separator ""
      opts.separator "Options -----------------------"
      opts.separator ""

      opts.on("-v", "--version VERSION",
        "The gem version to use. Any valid gem spec",
        "version expression can be specified."
      ) { |value| @options[:version] = value }

      opts.on("-o", "--only-dependencies",
      "Update only gem dependencies but not itself."
      ) { @options[:deps_only] = true }
      
      opts.on("-d", "--debug",
      "Prints some additional debug information."
      ) { @options[:debug] = true }

      opts.on("-h", "--help", "Display this help message") do
        puts opts
        exit
      end

      opts.separator ""
      opts.separator "Actions -----------------------"
      opts.separator ""
      opts.separator <<-DETAILS.split(/\n/)
  push -- pushes gems to the base gem server
  publish -- builds a gem from the current directory and pushes it to the base gem server
  build -- builds a gem from the current directory
  update -- updates gems from the local gem server
  get -- updates gems from the local gem server for dependencies defined in config/manifest.yml
DETAILS

      if args.empty?
        $stderr.puts opts
        exit(-1)
      else
        opts.parse!(args)
        @opts = opts
      end
    end

    if args.size < 1
      $stderr.puts @opts
      exit(-1)
    end

    @options[:action] = args.shift
    @options[:name] = args.shift
  
  end

  def execute!
    begin
      process_aliases
      validate_arguments
    rescue => ex
      puts "Invalid arguments: #{ ex }"
      exit(-1)
    end
    begin
      Capistrano::CLI.new(converted_arguments).execute!
    rescue Exception => ex
      if @options[:debug]
        raise
      else
        puts "Failed to execute: #{ ex }"
        exit(-1)
      end
    end
  end
  
  
private

  def validate_arguments

    case
      when ['push', 'install'].include?(@options[:action]) && @options[:name].nil? then
        fail "You need to specify the name of the plugem to #{ @options[:action] }"
    end
  
  end

  def process_aliases
    case @options[:action]
      when 'up' then @options[:action] = 'update'
      when 'pack' then @options[:action] = 'build'
    end
  end
  
  def converted_arguments
  
    args = [ "plugem_#{ @options.delete(:action) }" ]
  
    @options.each do |k, v|
      args << "-s" << "plugem_#{ k }=#{ v }"
    end
  
    args
  
  end
  
  end
end
