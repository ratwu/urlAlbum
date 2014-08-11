Webnode = require 'webnode'
_       = require 'underscore'
fns     = require '../../lib/fns'
moment = require 'moment'

module.exports = (app)->
  # API基础控制器
  APIController = require('../../lib/api_controller')(app)

  # 加载model
  Website = app.model 'website'

  class WebsiteController extends APIController
    # 公共API
    # public: ['create']

    # 创建资源
    create: (req, res)->
      data = _.pick req.params, 'title', 'url', "description", "category" 
      data.uid = @user.id
      console.log data
      website = Website.build(data)
      errors = website.validate()
      throw @err 500, JSON.stringify(errors) if errors
      okfun = (m)=>
        res.send 201, m
      errorfun = (e)->
        console.log e
        res.send 500, e.code
      website.save().success(okfun).error(errorfun)
