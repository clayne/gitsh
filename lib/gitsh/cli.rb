require 'readline'
require 'optparse'
require 'gitsh/completer'
require 'gitsh/environment'
require 'gitsh/git_driver'
require 'gitsh/prompter'
require 'gitsh/version'

module Gitsh
  class CLI
    EX_OK = 0
    EX_USAGE = 64

    def initialize(opts={})
      driver_factory = opts.fetch(:driver_factory, GitDriver)

      @env = opts.fetch(:env, Environment.new)
      @git_driver = driver_factory.new(@env)
      @readline = opts.fetch(:readline, Readline)
      @unparsed_args = opts.fetch(:args, ARGV).clone
    end

    def run
      parse_arguments
      if unparsed_args.any?
        exit_with_usage_message
      else
        run_interactive
      end
    end

    private

    attr_reader :env, :readline, :unparsed_args, :git_driver

    def run_interactive
      readline.completion_append_character = nil
      readline.completion_proc = Completer.new(readline)

      while command = read_command
        git_driver.execute(command)
      end

      env.print "\n"
    rescue Interrupt
      env.print "\n"
      retry
    end

    def read_command
      command = readline.readline(prompt, true)
      if command && command.empty?
        command = 'status'
      end
      command != 'exit' && command
    end

    def prompt
      prompter.prompt
    end

    def prompter
      @prompter ||= Prompter.new(color: color_support?)
    end

    def color_support?
      output, error, exit_status = Open3.capture3('tput colors')
      exit_status.success? && output.chomp.to_i > 0
    end

    def exit_with_usage_message
      env.puts_error option_parser.banner
      exit EX_USAGE
    end

    def parse_arguments
      option_parser.parse!(unparsed_args)
    rescue OptionParser::InvalidOption => err
      unparsed_args.concat(err.args)
    end

    def option_parser
      OptionParser.new do |opts|
        opts.banner = 'usage: gitsh [--version] [-h | --help] [--git PATH]'

        opts.on('--git [COMMAND]', 'Use the specified git command') do |git_command|
          env.git_command = git_command
        end

        opts.on_tail('--version', 'Display the version and exit') do
          env.puts VERSION
          exit EX_OK
        end

        opts.on_tail('--help', '-h', 'Display this help message and exit') do
          env.puts opts
          exit EX_OK
        end
      end
    end
  end
end
