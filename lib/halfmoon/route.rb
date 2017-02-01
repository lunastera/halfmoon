require 'erb'
require 'pp'

module HalfMoon
  # Routing
  class Route
    attr_reader :var_rexp

    def initialize(mapping)
      @dict_path = {}
      @var_path = []
      buf = compile_path_regexp(mapping, '', '')
      @var_rexp = Regexp.compile(buf.gsub(%r{\|\([^./]+}, '(?:'))
    end

    # debug
    def instances
      # p @var_path
      p @dict_path
    end

    def action_variables(request_path)
      # request_pathの最後に'/'があれば削除
      request_path.chop! if request_path.gsub!(%r{/+}, '/')[-1] == '/'
      # 正規表現で何番目のvar_url_listにマッチするか調べる
      find_route = @var_rexp.match(request_path) #/users/show
      # var_url_listのものでない(nil)ならば、O(1)でHashから検索
      if find_route.nil?
        actions = @dict_path[request_path]
        dict = nil
      else
        rexp, names, actions = @var_path[find_route.captures.find_index('')]
        values = rexp.match(request_path).captures
        dict = Hash[names.zip(values)]
      end

      # 存在しなければ404
      return { File: 404, Action: nil, PathV: nil } if actions.nil?
      file, action = actions.split(/\//)
      # メソッド未定義ならindexメソッド
      action = 'index' if action.nil?
      # FilePath, ClassName, MethodName, PathValiable
      { File: file, Action: action, PathV: dict }
    end

    private

    # mappingを加工する
    def compile_path_regexp(mapping, base_path, current_path)
      buff = []
      current_fullpath = "#{base_path}#{current_path}" # /users
      mapping.each do |path, action|
        if action.is_a?(Array)
          buff << path
          buff << compile_path_regexp(action, current_fullpath, path)
        elsif action.is_a?(String)
          buff << compile_match_list(path, current_fullpath, action)
        end
      end
      buff.compact!
      compile_var_regexp(buff)
    end

    # マッチング用のデータを作成
    def compile_match_list(path, current_fullpath, action)
      # puts "'#{path}' => #{current_fullpath} #{action}"
      if (var = path.scan(/:\w+/)) != []
        reg_path = path.gsub(%r{:[^./]+}, '(\w+)')
        require_action(action)
        @var_path << [
          Regexp.compile("\\A#{current_fullpath + reg_path}\\z"),
          var.map { |str| str.delete(':') },
          action
        ]
      else
        # puts "'#{path}' => #{current_fullpath} #{action}"
        @dict_path[current_fullpath + path] = action
      end
      # からパスだけ・・・？
      path.gsub(%r{:[^./]+}, '\w+') + '(\z)' if path.scan(/:\w+/) != []
    end

    # var_url_listの場合、場所を特定する正規表現も必要なので作成
    def compile_var_regexp(buff)
      return nil if buff.empty?
      return "(?:#{buff.first})" if buff.length == 1
      "(?:#{buff.join('|')})"
    end

    # 指定されたパスが存在しているか
    def require_action(action)
      file, action = action.split(/\//)
      begin
        require Config[:root] + Config[:ctrl_path] + file
      rescue LoadError => ex
        p Config[:root] + Config[:ctrl_path] + file
        raise ex, 'specified file does not exist.'
      end
    end
  end
end

# require_relative './routes.rb'
#
# ins = HalfMoon::Route.new($mapping)
# ins.instances
