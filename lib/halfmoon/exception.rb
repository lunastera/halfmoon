
# require 'halfmoon/exceptions/show'

module HalfMoon
  HTTP_RESPONSE_STATUS = {
    100 => 'Continue',
    101 => 'Switching Protocols',
    102 => 'Processing',
    200 => 'OK',
    201 => 'Created',
    202 => 'Accepted',
    203 => 'Non-Authoritative Information',
    204 => 'No Content',
    205 => 'Reset Content',
    206 => 'Partial Content',
    207 => 'Multi-Status',
    208 => 'Already Reported',
    226 => 'IM Used',
    300 => 'Multiple Choices',
    301 => 'Moved Permanently',
    302 => 'Found',
    303 => 'See Other',
    304 => 'Not Modified',
    305 => 'Use Proxy',
    307 => 'Temporary Redirect',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Timeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Request Entity Too Large',
    414 => 'Request-URI Too Long',
    415 => 'Unsupported Media Type',
    416 => 'Requested Range Not Satisfiable',
    417 => 'Expectation Failed',
    418 => 'I\'m a teapot',
    422 => 'Unprocessable Entity',
    423 => 'Locked',
    424 => 'Failed Dependency',
    426 => 'Upgrade Required',
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable',
    504 => 'Gateway Timeout',
    505 => 'HTTP Version Not Supported',
    506 => 'Variant Also Negotiates',
    507 => 'Insufficient Storage',
    508 => 'Loop Detected',
    510 => 'Not Extended'
  }.each { |_, v| v.freeze }

  # HTTPException
  class HTTPException < Exception
    attr_reader :status_code, :message, :response_header

    # @param [Int] status_code ステータスコード
    # @param [String] message=nil エラーメッセージ
    # @param [Hash] response_header=nil レスポンスとして返すHeader
    def initialize(status_code, message = nil, response_header = nil)
      @status_code      = status_code
      @message          = message         if message
      @response_header  = response_header if response_header
    end

    def status_message
      HTTP_RESPONSE_STATUS[@status_code]
    end
  end

  # エラーが起きた際に表示するページを生成するコード
  class ShowException
    def initialize(status_code)
      # @status_code = status_code
      @status = {}
      @status[:Code] = status_code
      @status[:Mes]  = HTTP_RESPONSE_STATUS[status_code]
    end

    def show
      path = Config[:root] + '/app/exceptions/'
      files = Dir.glob(path + '*.erb')
      if files.include?(path + @status[:Code].to_s + '.erb')
        body = ERB.new(
          File.open(path + @status[:Code].to_s + '.erb').read
        ).result(binding)
      else
        body = ERB.new(
          File.open(path + 'default.erb').read
        ).result(binding)
      end
      [@status[:Code], { 'Content-Type' => 'text/html' }, [body]]
    end
  end
end
