
require 'rack'
require 'erb'
require 'sequel'
require 'cgi'

# other
require 'halfmoon/config'
require 'halfmoon/exception'
require 'halfmoon/route'
require 'halfmoon/action'
require 'halfmoon/loader'
require 'halfmoon/db'
require 'halfmoon/migration'
require 'halfmoon/cli'

module HalfMoon
  extend HalfMoon::Loader

  VERSION = '0.1.2'.freeze

  class << self
    @application = @app_class = nil

    attr_accessor :application, :app_class
    def application
      @application ||= (app_class if app_class)
    end
  end

  # Action executed Class
  class ActionExecution
    # @params [Hash] action_args File: ファイル名, Action: 実行されるメソッド, PathV: パスパラメータ
    def initialize(action_args)
      @args = action_args
    end

    def response_action(req)
      HalfMoon.hm_load "#{Config[:ctrl_path]}#{@args[:file]}_controller"
      klass = "#{@args[:file].capitalize}Controller"
      ins = Kernel.const_get(klass).new(compile_params(req))
      return if before_action(ins)
      return if main_action(ins)
      return if after_action(ins)
    end

    private

    def before_action(ins)
      ins.before_action
      response.redirect?
    end

    def main_action(ins)
      if (body = ins.send(@args[:action].to_sym)).is_a?(HalfMoon::Raw)
        response.write(body)
      elsif !response.redirect?
        response.write(ins.default_rendering(@args[:file], @args[:action]))
      end
      response.redirect?
    end

    def after_action(ins)
      ins.after_action
      response.redirect?
    end

    def compile_params(req)
      get = req.GET.map { |k, v| [k.to_sym, v] }.to_h # keyをsymbol化して返す
      post = req.POST.map { |k, v| [k.to_sym, v] }.to_h
      { paths: @args[:path_v], get: get, post: post, session: req.session }
    end

    def response
      HalfMoon.application.response
    end
  end

  # ResponseClass
  class Response < Rack::Response
    def clear
      initialize
    end
  end

  # bodyObject
  class Raw < String
    def initialize(str)
      super CGI.pretty(str.gsub(/^\s+|[\r\n]+/, ''))
    end
  end

  # RackApplication
  class Application
    attr_accessor :response
    def initialize(mapping = nil)
      @route = Route.new(mapping)
      HalfMoon.app_class = self
    end

    def call(env)
      response.clear
      req = Rack::Request.new(env)
      args = @route.action_variables(req.path_info)
      if args[:file] == 404
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
