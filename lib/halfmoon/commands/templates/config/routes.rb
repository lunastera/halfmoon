#
# 以下は記述例です。
#
# generate do
#   request '', 'index/index' # アクションの指定をStringにした場合はGETリクエストとして処理されます。
#   parent  '/users' do       # ネストする場合parentを使って纏めて下さい。
#     request '', 'users/index' # この場合は /users/index にマッチします。
#     # 第2引数以降にハッシュを指定すればkeyのメソッドの場合はvalueの処理、と言う分け方ができます。
#     request '', GET: 'users/index', POST: 'users/show'
#   end
# end
#
# /:<name> はURLパスパラメータとして取得できます。
# もしあなたがこの値を利用したい場合はControllerかViewで paths[:<name>] を呼び出して下さい。
#
