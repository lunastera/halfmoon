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
# /:<name> is URL Path Parameter
# You can retrieve the value by calling @paths [: <name>] in Controller or View.
