require 'halfmoon'
require 'halfmoon/config'
require_relative './app/config/routes.rb'
require_relative './app/config/config.rb'
extend HalfMoon::RouteDelegator

app = HalfMoon::Application.new(mapping)

require 'rack/session/cookie'
app = Rack::Session::Cookie.new(app, Config.get_all(/session_/))
# useの方でなければurls:に配列を指定できない? 要検証
use Rack::Static, urls: Config[:assets_dir], root: Config[:assets_root]

run app
