module HalfMoon
  # handle commands
  class CLI
    def initialize
      command = ARGV.shift
      command_handler(command)
    end

    def server
      require_command 'server'
      Server.start
    end

    def generator
      unless File.exist?('config.ru')
        puts "'config.ru' is not found."
        exit(1)
      end
      require_command 'generator'
      target = ARGV.shift
      switch_generate(target)
    end

    def switch_generate(target)
      case target
      when 'controller'
        ctrl_name = ARGV.shift
        ControllerGenerator.start([ctrl_name, ARGV])
      when 'model'
        model_name = ARGV.shift
        ModelGenerator.start([model_name, ARGV])
      else
        puts "#{target} command is not found"
        exit(1)
      end
    end

    def new
      require_command 'generator'
      project_name = ARGV.length.zero? ? 'MyApp' : ARGV.shift
      ProjectGenerator.start([project_name])
    end

    def command_handler(command)
      new if command =~ /^n$|^new$/
      server if command =~ /^s$|^server$/
      generator if command =~ /^g$|^generator$/
    end

    private

    def require_command(command)
      require "halfmoon/commands/#{command}"
    end
  end
end
