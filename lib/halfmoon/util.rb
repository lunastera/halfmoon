require 'uri'

module HalfMoon
  # 必要な定数を宣言する
  HTTP_REQUEST_METHODS = {
    'GET'     => :GET,
    'POST'    => :POST,
    'PUT'     => :PUT,
    'DELETE'  => :DELETE,
    'HEAD'    => :HEAD,
    'PATCH'   => :PATCH,
    'OPTIONS' => :OPTIONS,
    'TRACE'   => :TRACE
  }.freeze

  EACAPE_HTML = {
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    "'" => '&#x27;',
    '"' => '&quot;',
    '/' => '&#x2F;'
  }.each { |_, v| v.freeze }

  # Utils
  module Util
    def html_escape(str)
      str.gsub(%r{[&<>'"/]}, ESCAPE_HTML)
    end
    alias h html_escape

    def percent_encode(str)
      URI.encode(str)
    end

    def paercent_decode(str)
      URI.decode(str)
    end
  end
end
