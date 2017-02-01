require 'digest/sha2'
# Main config
class Config < ConfigBase
  # app setting
  add :serv_port,    '8282'

  # database settings
  add :db_host,      'localhost'
  add :db_port,      '8888'
  add :db_user,      'root'
  add :db_pass,      'root'
  add :db_name,      'default.db'

  # path setting
  add :ctrl_path,   '/app/controller/'
  add :view_path,   '/app/view/'
  add :model_path,  '/app/model/'
  add :db_path,     '/app/db/'
  add :def_act,     'index'
  add :assets_dir,  ['/favicon.ico', '/assets'] # 注: 1
  add :assets_root, 'app'

  # session setting
  add :session_key, 'application_session'
  add :session_domain, nil
  add :session_path, '/'
  add :session_expire_after, 60 * 60 # Cookieの有効期限 1時間
  add :session_secret, Digest::SHA256.hexdigest(rand.to_s) # セキュリティの関係上必ず設定すること!!
end

# 注: 1
# favicon.icoにアクセスできるようにしておかなければ
# ブラウザを再起動した以降、staticページを参照できなくなる
