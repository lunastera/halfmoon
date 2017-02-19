module HalfMoon
  # Routing
  class Router
    def initialize(mapping)
      @dict_paths = {}
      @var_paths = []
      buf = compile_path_regexp(mapping, '', '')
      @var_rexp = Regexp.compile(buf.gsub(%r{\|\(\?:+}, '(?:')) unless buf.nil?
      @var_rexp = /[^\w\W]/ unless @var_rexp.to_s =~ /\(\\z\)/
    end

    def action_variables(request_path)
      # request_pathの最後に'/'があれば削除
      request_path.chop! if request_path.gsub!(%r{/+}, '/')[-1] == '/'
      if @dict_paths.key?(request_path)
        action = @dict_paths[request_path]
        dict = nil
      else
        find_route = @var_rexp.match(request_path)
        unless find_route.nil?
          # rexp, names, action = @var_paths[find_route.captures.find_index('')]
          route_data = @var_paths[find_route.captures.find_index('')]
          action = route_data[:action]
          values = route_data[:rexp].match(request_path).captures
          dict = Hash[route_data[:path_names].zip(values)]
        end
      end
      # { action : { Method: 'controller/method' }, path_v: { path_name: 'value' } }
      { action: action, path_v: dict }
    end

    private

    # mappingを加工する
    def compile_path_regexp(mapping, base_path, current_path)
      buff = []
      current_fullpath = "#{base_path}#{current_path}"
      mapping.each do |path, action|
        if action.is_a?(Array)
          buff << variable_of(path)
          buff << compile_path_regexp(action, current_fullpath, path)
        elsif action.is_a?(String)
          action = { GET: action }
          buff << compile_match_list(path, current_fullpath, action)
        elsif action.is_a?(Hash)
          buff << compile_match_list(path, current_fullpath, action)
        end
      end
      buff.compact!
      compile_var_regexp(buff)
    end

    def variable_of(path)
      return path if path.scan(%r{:[^./]+}) == []
      path.gsub(%r{:[^./]+}, '\w+')
    end

    # マッチング用のデータを作成
    def compile_match_list(path, current_path, action)
      current_fullpath = "#{current_path}#{path}"
      if (var = current_fullpath.scan(/:\w+/)) != []
        reg_path = current_fullpath.gsub(%r{:[^./]+}, '(\w+)')
        action.each { |_, v| require_action(v) }
        @var_paths << {
          rexp: Regexp.compile("\\A#{reg_path}\\z"),
          path_names: var.map { |str| str.delete(':').to_sym },
          action: action
        }
      else
        @dict_paths[current_fullpath] = action
      end
      (current_fullpath.scan(/:\w+/) == [] ? nil : "#{variable_of(path)}(\\z)")
    end

    # var_url_listの場合、場所を特定する正規表現も必要なので作成
    def compile_var_regexp(buff)
      return nil if buff.empty?
      return "(?:#{buff.first})" if buff.length == 1
      "(?:#{buff.join('|')})"
    end

    def lookup
      puts '*' * 50
      print 'dicts: '
      pp @dict_paths
      print 'paths: '
      pp @var_paths
      print 'rexp : '
      pp @var_rexp
      puts '*' * 50
    end

    # 指定されたパスが存在しているか
    def require_action(action)
      file = action.split('/').first
      begin
        require "#{Config[:root]}#{Config[:ctrl_path]}#{file}_controller"
      rescue LoadError => ex
        p Config[:root] + Config[:ctrl_path] + file
        raise ex, 'specified file does not exist.'
      end
    end
  end

  # RoutingGenerate
  class RouteGenerator
    class << self
      attr_reader :mapping
      def generate(&_)
        @mapping = {}
        @buffs = {}
        @current = []
        yield
      end

      def parent(path, &_)
        @current << path
        @buffs[@current.last] = [] # 現在のパスに対応する値を初期化
        @buffs[@current.join] = [] # 現在のパスまでのフルパス 名前空間として使用
        yield
        if @current.size == 1      # 最初のパスなら全てのbufferを現在のパスと紐付ける
          @mapping[path] = @buffs[path]
        else
          @buffs[@current.select{ |item| item != path }.join] << [path, @buffs[@current.join]]
        end
        @current.pop
      end

      def request(path, *args)
        if @current.empty?
          @mapping[path] = args.first
        else
          @buffs[@current.join] << [path, args.first] # [/pre/city/town] << ['', 'hoge/action']
        end
      end
    end
  end

  # Objectclassdelegate
  module RouteDelegator
    class << self
      attr_accessor :target
    end
    self.target = HalfMoon::RouteGenerator
    def self.delegate(*methods)
      methods.each do |method_name|
        define_method method_name do |*args, &block|
          RouteDelegator.target.send(method_name, *args, &block)
        end
      end
    end

    delegate :generate, :request, :parent, :mapping
  end
end
