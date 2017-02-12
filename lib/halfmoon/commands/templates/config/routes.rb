#
# Write routing settings in this file.
# An example of description is as follows.
#
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
#
# ['RequestPath', 'ControllerFileName/MethodName']
#
# OR
#
# HalfMoon::Route.generate do |r|
#   r.root '',            'pages/index'
#   r.root '/:id',        'pages/show'
#   r.parent '/debug' do
#     r.get '',           'debug/index'
#     r.get '/:id',       'debug/show'
#     r.get '/:name/:id', 'debug/show'
#   end
#   r.parent '/users' do
#     r.get '',           'users/index'
#     r.get '/show',      'users/show'
#     r.get '/show/:id',  'users/show'
#   end
# end
#
# /:<name> is URL Path Parameter
# You can retrieve the value by calling @paths [:<name>] in Controller or View.
#
