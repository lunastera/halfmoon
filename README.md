## HalfMoon

これはRuby製Webアプリケーションフレームワーク「HalfMoon」です。

## 概要

特によく使う機能をまとめたWebアプリケーションフレームワークです。  
学習コストが低く、高速に動作するのが特徴です。自身の学習目的で作成しました。  
Sinatra、Rails、k8rbを参考に作られています。

- ホットデプロイ対応（ルーティング設定以外）
- MVC構造
- 高速

### インストール

    git clone https://github.com/sobreera/halfmoon.git
    cd halfmoon

bundleでインストールする場合

    bundle install

gem installして使用する場合

    rake build
    gem install -b pkg/halfmoon-<Version>.gem -V


## クイックリファレンス

### コマンド一覧

1. 全てのコマンドは先頭の一文字に省略可能です。  
例:  
`halfmoon server` -> `halfmoon s`  
`halfmoon generate controller` -> `halfmoon g c`

2. bundlerでインストールした場合はコマンドの
`halfmoon`を`bundle exec <bin/halfmoonを相対指定>`に変えて下さい。

例: halfmoonディレクトリ  

    bundle exec bin/halfmoon

例2: プロジェクトフォルダ

    bundle exec ../bin/halfmoon

**# プロジェクトの作成**

プロジェクトを作成します。  
以下のコマンドをうつと必要なファイル群が生成されます。

    halfmoon new <プロジェクト名>

`<プロジェクト名>`部分は省略可能です。  
省略した場合プロジェクト名はMyAppとなります。

プロジェクト名は後から変更可能です。  
以降のコマンドはプロジェクトフォルダに移動した状態で入力して下さい。

    cd <プロジェクト名>

**# コントローラの作成**

Controllerと対応するViewを作成します。  
メソッドは複数指定しても問題ありません。

    halfmoon generate controller <コントローラ名> [定義したいメソッド]

**# モデルの作成**

Modelクラスとそれに対応するMigrationファイルを作成します。  
`<モデル名>`は単数形なことに注意して下さい。

    halfmoon generate model <モデル名>

### Rakeコマンド

**# マイグレーションの実行**

`<テーブル名>`は複数形なことに注意して下さい。

    rake db:migration[<テーブル名>,<実行するメソッド>]

**# シードの実行**

seeds.rbに記述されたデータの操作を適応します。  
DBを初期化する際に使って下さい。

    rake db:seed

### ルーティングの設定

必ずgenerateの中に記述して下さい。  

app/config/routes.rb
```ruby
generate do
  request '', 'pages/index'
  parent '/users' do
    request '', 'users/index'
    request '/:id', 'users/show'
  end

  parent '/:prefecture' do
    parent '/:city' do
      parent '/:town' do
        request '', GET: 'prefecture/show', POST: 'prefecture/create'
      end
    end
  end
end
```

- `parent '/<パス>'`でネストさせることができます。  
- `request '/:<識別名>'`とするとControllerやViewで`paths[:<識別名>]`というコードでパスを取得できます。
- `reqeust '/<パス>'`以降の引数は二種類存在します。
  - Stringのみで指定した場合、`GET: 引数`が定義されます。
  - Hash（メソッド名: アクション）で指定した場合、それぞれ定義されます。

もしGETしか定義されていないものに対して他のメソッドがリクエストされた場合はGETのアクションを実行します。

### サーバ起動

config.ruが存在しているディレクトリで

    halfmoon server
