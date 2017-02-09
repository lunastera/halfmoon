require 'halfmoon/db'
require 'halfmoon/loader'
# Action
class Action
  extend HalfMoon::Loader

  MIME_TYPES = Rack::Mime::MIME_TYPES

  def initialize(params)
    @paths = params[:Paths]
    @get   = params[:GET]
    @post  = params[:POST]
    @session = params[:Session]
    Action.all_autoload Config[:root] + Config[:model_path] + '*.rb'
    @db = HalfMoon::DB.sqlite
  end

  # 必ずアクション前に実行される処理
  def before_action
  end

  # 必ずアクション後に実行される処理
  def after_action
  end

  # このメソッドのbinding
  def bind
    binding
  end

  # @param [Symbol] model_name 使用するモデルの名前
  # @param [String, nil] file_name 使用するモデルのパス
  def self.use_model(model_name, file_name = nil)
    file_name = Config[:root] + Config[:model_path] + model_name.to_s.downcase + '.rb' if file_name.nil?
    load file_name
  end

  def session
    @session
  end

  protected

  def render(file)
    view_path = Config[:root] + Config[:view_path]
    file_path = Dir.glob(view_path + "#{file}*").first # /path/to/index.html.erb
    filename = file_path.split('/').last               # ex: index.html.erb
    mime_type = filename.split('.')[1]                 # ex: html
    body = ERB.new(
      File.open(file_path).read
    ).result(binding)
    HalfMoon.application.response['Content-Type'] = MIME_TYPES[".#{mime_type}"]
    HalfMoon.application.response.write(body)
    body
  end

  def redirect_to(path)
    HalfMoon.application.response['Location'] = path
    HalfMoon.application.response.write('')
  end
end
