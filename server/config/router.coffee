module.exports = (Router)->
  Router.get '/api', 'index#index'
  
  # Router.get '/api/user', 'user#session'

  #login接口

  #user接口
  Router.get '/api/user', 'user#index' #获取所有用户列表
  Router.get '/api/user/:id', 'user#get' #查看指定用户
  Router.post '/api/user', 'user#create' #新建用户
  Router.del '/api/user/:id', 'user#delete' #新建用户
  Router.put '/api/user/:id', 'user#put' #更新user接口
  Router.post '/api/password', 'user#password' #更新user密码接口

  #添加自定义网址接口
  Router.post '/api/website', 'website#create' #新建自定义网址
  # Router.get '/api/website', 'website#create' #新建自定义网址



