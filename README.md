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

    bundle exec ../bin/halfmoon generator controller users index show

#### モデルの作成

    bundle exec ../bin/halfmoon generator model users

### ルーティングの設定

app/config/route.rb
```ruby
HalfMoon::Route::generate do |r|
  r.root '/user' do
    r.get '/index', 'users/index'
    r.get '/:id',   'users/show'
  end
end
```

### 起動

config.ruが存在しているディレクトリで

    bundle exec ../bin/halfmoon server
