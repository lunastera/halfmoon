require 'halfmoon/db'
require 'halfmoon/loader'
# Action
class Action
  extend HalfMoon::Loader
  attr_accessor :params
  MIME_TYPES = Rack::Mime::MIME_TYPES
  VALIDATE   = [:response].freeze

  def self.method_added(name)
    return if self == Action
    remove_method(name) if Action.instance_eval { VALIDATE.include?(name) }
  end

  def initialize(params)
    @params = params
    Action.all_autoload "#{Config[:root]}#{Config[:model_path]}*.rb"
    @db = HalfMoon::Database.connect
  end

  def paths;  @params[:paths];  end
  def get;    @params[:get];    end
  def post;   @params[:post];   end
  def session;@params[:session];end
  alias GET get
  alias POST post
  alias SESSION session

  # 必ずアクション前に実行される処理
  def before_action
  end

  # 必ずアクション後に実行される処理
  def after_action
  end

  def default_rendering(klass, method)
    render "#{klass}/#{method}"
  end

  protected

  def render(file, *opts)
    opts = opt_parser(opts)
    base_path = "#{Config[:root]}#{Config[:view_path]}#{file.gsub('/', '/*')}"
    files = Dir.glob("#{base_path}*")
    if files.length == 1
      file_path = files.first
    else
      files.each do |path|
        file_path = path if path.split('.').last == opts[:template]
      end
    end
    file_path.files.first if file_path.nil?
    unless (file_info = file_path.split('/').last.split('.')).first[0] == '_'
      mime_type = file_info[1] # ex: html
      response['Content-Type'] = MIME_TYPES[".#{mime_type}"]
    end
    HalfMoon::Raw.new(Tilt.new(file_path).render(self))
  end

  def opt_parser(opts)
    opts = opts.first.is_a?(Hash) ? opts.first : {}
    return opts if opts[:template].nil?
    if !opts[:template].is_a?(Symbol) && !opts[:template].is_a?(String)
      raise TypeError, 'format option is specified by String or Symbol.'
    end
    opts[:template] = opts[:template].to_s if opts[:template].is_a?(Symbol)
    opts
  end

  def redirect_to(path)
    response.redirect(path)
  end

  def response
    HalfMoon.application.response
  end
end
