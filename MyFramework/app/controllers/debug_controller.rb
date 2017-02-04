# TestController
class DebugController < Action
  def initialize(params)
    super(params)
    # user = User.new             # usersテーブルに行を追加するよ！
    # user.name = 'ふがふが'       # usersのnameの値に'ほげほげ'を設定
    # user.pass = 'fugafuga123'   # usersのpassの値に'hogehoge123'を設定
    # user.save                   # INSERT文発行！
    @users = User.all # SELECT * FROM users
  end

  def index
    @action = { Class: fullname, Method: __method__ }
    session[:hoge] = 'Session格納確認' if session[:hoge].nil?
    render(:html, 'debug/debug') # view/debug/debug.erbをHTMLとしてレスポンスを返している！
  end

  def show
    @action = { Class: fullname, Method: __method__ }
    # redirect_to('/debug') # リダイレクトしたい場合
    render(:html, 'debug/debug')
  end

  def fullname
    self.class.to_s
  end
end
