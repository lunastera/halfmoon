
require 'rack'
require 'erb'
require 'sequel'

# other
require 'halfmoon/config'
require 'halfmoon/exception'
require 'halfmoon/util'
require 'halfmoon/route'
require 'halfmoon/action'
require 'halfmoon/loader'
require 'halfmoon/db'
require 'halfmoon/migration'
require 'halfmoon/cli'

module HalfMoon
  extend HalfMoon::Loader

  VERSION = '0.1.0'.freeze

  class << self
    @application = @app_class = nil

    attr_accessor :application, :app_class
    def application
      @application ||= (app_class if app_class)
    end
  end

  # Action matched Class
  class ActionExecution
    # @params [Hash] action_args File: ファイル名, Action: 実行されるメソッド, PathV: パスパラメータ
    def initialize(action_args)
      @args = action_args
    end

    def response_action(req)
      HalfMoon.hm_load Config[:ctrl_path] + @args[:File] + '_controller'
      klass = @args[:File].capitalize + 'Controller'
      ins = Kernel.const_get(klass).new(compile_params(req))
      ins.before_action
      ins.send(@args[:Action].to_sym)
      ins.after_action
    end

    def compile_params(req)
      get = req.GET
      post = req.POST
      { Paths: @args[:PathV], GET: get, POST: post, Session: req.session }
    end
  end

  class Response < Rack::Response
    def clear
      initialize
    end
  end

  # RackApplication
  class Application
    attr_accessor :response
    def initialize(mapping = nil)
      @route = Route.new(mapping)
    end

    def call(env)
      response.clear unless response.empty?
      HalfMoon.app_class = self
      req = Rack::Request.new(env)
      args = @route.action_variables(req.path_info)
      if args[:File] == 404
        ex = ShowException.new(404)
        return ex.show
      end
      act_match = ActionExecution.new(args)
      act_match.response_action(req)
      response.finish
    end

    def response
      @response ||= Response.new
    end
  end
end
