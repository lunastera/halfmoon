module HalfMoon
  class Server < ::Rack::Server
    def initialize(*)
      super
      set_environment
    end

    def set_environment
      ENV['HM_ENV'] ||= options[:environment]
    end

    def default_options
      environment  = ENV['HM_ENV'] || ENV['RACK_ENV'] || 'development'
      default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

      {
        environment:  environment,
        pid:          nil,
        Port:         8282,
        Host:         default_host,
        AccessLog:    [],
        config:       'config.ru'
      }
    end
  end
end
