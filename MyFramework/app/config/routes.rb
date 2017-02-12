# 'URL', 'controller/method'
# $mapping = [
#   ['', 'debug/index'],
#   ['/debug', [
#     ['',           'debug/index'],
#     ['/:id',       'debug/show'],
#     ['/:name/:id', 'debug/show']
#   ]],
#   ['/users', [
#     ['',           'users/index'],
#     ['/show',      'users/show'],
#     ['/show/:id',  'users/show']
#   ]]
# ]

HalfMoon::Route.generate do |r|
  r.parent '/debug' do
    r.get '',           'debug/index'
    r.get '/:id',       'debug/show'
    r.get '/:name/:id', 'debug/show'
  end
  r.parent '/users' do
    r.get '',           'users/index'
    r.get '/show',      'users/show'
    r.get '/show/:id',  'users/show'
  end
end
