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
HalfMoon::Route::generate do |r|
  r.root '',        'pages/index'
  r.parent '/user' do
    r.get '/index', 'users/index'
    r.get '/:id',   'users/show'
  end
end
```

### 起動

config.ruが存在しているディレクトリで

    bundle exec ../bin/halfmoon server
