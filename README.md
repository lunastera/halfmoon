## 使い方

### インストール

```
git clone https://github.com/sobreera/halfmoon.git
cd halfmoon
bundle install
```

### 各ジェネレータ

#### プロジェクトの作成

```
bundle exec bin/halfmoon new exampleProject
cd exampleProject
```

#### コントローラーの作成

    bundle exec ../bin/halfmoon generate controller users index show

#### モデルの作成

    bundle exec ../bin/halfmoon generate model users

### ルーティングの設定

app/config/routes.rb
```ruby
generate do
  # 文字列で指定した場合GETリクエストとなる
  request '', 'pages/index' # localhost:8282
  parent '/pages' do
    request '/index', GET: 'pages/index'  # localhost:8282/index
    # Hashで指定する場合複数のリクエストメソッドを定義できる
    # またURLパスパラメータを取得できる
    request '/:id',   GET: 'pages/show', POST: 'pages/show'
  end
end
```

### 起動

config.ruが存在しているディレクトリで

    bundle exec ../bin/halfmoon server
