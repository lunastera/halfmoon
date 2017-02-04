
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
  # Action matched Class
  class ActionMatching
    # @params [Hash] action_args File: ファイル名, Action: 実行されるメソッド, PathV: パスパラメータ
    def initialize(action_args)
      @args = action_args
    end

    def response_action(req)
      HalfMoon.hm_load Config[:ctrl_path] + @args[:File] + '_controller'

      klass = @args[:File].capitalize + 'Controller'
      ins = Kernel.const_get(klass).new(compile_params(req))
      ins.before_action
      res = ins.send(@args[:Action].to_sym)
      ins.after_action
      res
    end

    def compile_params(req)
      get = req.GET
      post = req.POST
      { Paths: @args[:PathV], GET: get, POST: post, Session: req.session }
    end
  end

  # RackApplication
  class Application
    def initialize(mapping = nil)
      @route = Route.new(mapping)
    end

    def call(env)
      req = Rack::Request.new(env)
      args = @route.action_variables(req.path_info)
      if args[:File] == 404
        ex = ShowException.new(404)
        return ex.show
      end
      act_match = ActionMatching.new(args)
      res = act_match.response_action(req)
      res
    end
  end
end
