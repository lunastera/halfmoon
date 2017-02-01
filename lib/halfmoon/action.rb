require 'halfmoon/db'
require 'halfmoon/loader'
# Action
class Action
  extend HalfMoon::Loader

  MIME_TYPES = {
    html: 'text/html',
    json: 'application/json'
  }.freeze

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

  def render(mime_type, file)
    view_path = Config[:root] + Config[:view_path]
    header = { 'Content-Type' => MIME_TYPES[mime_type] }
    body = ERB.new(
      File.open(view_path + file + '.erb').read
    ).result(binding)
    [200, header, [body]]
  end

  def redirect_to(path)
    [303, { 'Location' => path }, ['']]
  end
end
