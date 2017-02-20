
require 'rack'
require 'tilt'
require 'sequel'
require 'cgi'

# other
require 'halfmoon/config'
require 'halfmoon/exception'
require 'halfmoon/router'
require 'halfmoon/action'
require 'halfmoon/loader'
require 'halfmoon/db'
require 'halfmoon/migration'
require 'halfmoon/cli'

module HalfMoon
  extend HalfMoon::Loader

  VERSION = '0.3.0'.freeze

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
      file, action = request_handler(req.request_method).split('/')
      HalfMoon.hm_load "#{Config[:ctrl_path]}#{file}_controller"
      klass = "#{file.capitalize}Controller"
      ins = Kernel.const_get(klass).new(compile_params(req))
      return if before_action(ins)
      return if main_action(ins, file, action)
      return if after_action(ins)
    end

    private

    def request_handler(request_method)
      action = nil
      @args.each do |m, a|
        if request_method.to_sym == m
          action = a
          break
        end
      end
      action = @args[:action][:GET] if action.nil?
      action
    end

    def before_action(ins)
      ins.before_action
      response.redirect?
    end

    def main_action(ins, file, action)
      if (body = ins.send(action.to_sym)).is_a?(HalfMoon::Raw)
        response.write(body)
      elsif !response.redirect?
        response.write(ins.default_rendering(file, action))
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
      format = (f = req.path_info.split('.')).length == 1 ? nil : f.last
      { paths: @args[:path_v], get: get, post: post, session: req.session, format: format }
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
      @route = Router.new(mapping)
      HalfMoon.app_class = self
    end

    def call(env)
      response.clear
      req = Rack::Request.new(env)
      request_path = path_filter_format(req.path_info)
      args = @route.action_variables(request_path)
      return ShowException.new(404).show if args[:action].nil?
      act_match = ActionExecution.new(args)
      act_match.response_action(req)
      response.finish
    end

    def path_filter_format(path)
      return path if path.scan(/\./).empty?
      return path.chop! if path[-1] == '.'
      path.chop! if path.gsub!(%r{/+}, '/')[-1] == '/'
      paths = path.split('.')
      paths.pop
      paths.join('.')
    end

    def response
      @response ||= Response.new
    end
  end
end
