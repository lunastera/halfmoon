# 'URL', 'controller/method'
$mapping = [
  ['', 'debug/index'],
  ['/debug', [
    ['',           'debug/index'],
    ['/:id',       'debug/show'],
    ['/:name/:id', 'debug/show']
  ]],
  ['/users', [
    ['',           'users/index'],
    ['/show',      'users/show'],
    ['/show/:id',  'users/show']
  ]]
]
