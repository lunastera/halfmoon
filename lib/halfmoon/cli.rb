require 'thor'
require 'halfmoon'

module HalfMoon
  class CLI < Thor
    desc 'server', 'halfmoon server start'
    def server
      Dir.chdir(File.expand_path('../../', APP_PATH)) unless File.exist?(File.expand_path("config.ru"))
      require "halfmoon/server"
      HalfMoon::Server.new.tap do |server|
        require APP_PATH
        server.start
      end
    end
  end
end
