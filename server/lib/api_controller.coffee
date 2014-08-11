Webnode = require 'webnode'
Moment  = require 'moment'
_       = require 'underscore'

fns = require './fns'

module.exports = (app)->

  # 加载User模型
  User = app.model 'user'
  OpenMaster = require('./openmaster')(app)

  ReportError = (msg)->
    Webnode.Restify.RestError.call @,
      restCode: 'ReportError'
      statusCode: 506
      message: msg
      constructorOpt: ReportError
    @name = 'ReportError'

  class APIController extends Webnode.Controller

    # 调用方法
    callAction: (action, req, res, next)->
      # res.header("Set-Cookie", "accessToken=5d06e7dd0f92736b6c28b2d2d25221c8cb110c77;;path=/")
      res.set 'content-type', 'application/json;charset=utf-8'
      res.contentType = 'application/json'
      @checkSession action, req, (authed, user)=>
        throw @err 401, 'Invalid Cert' if not authed
        return super action, req, res, next if user is 'public'
        @user = user
        try
          super action, req, res, next
        catch error
          app.defaultErrorHandler()(req, res, null, error)

    checkSession: (action, req, cb) ->
      return cb yes, 'public' if action in (@public ? [])
      cookie = @parseCookie(req, 'accessToken')
      console.log cookie
      return cb no if not cookie
      OpenMaster.getUser cookie, (err, open_user)=>
        return cb no if !open_user
        open_user.accessToken = req.params.access_token
        open_user.expired     = new Date(Moment().add('minutes', 21600))
        User.find({where:{id:open_user.id}}).success((user)->
          if not user
            User.build(open_user).save().success (u)->
              cb yes, u
          else
            user.accessToken  = open_user.accessToken
            user.expired = open_user.expired
            user.save().success ()->
              cb yes, user
        ).error (err)=>
          throw @err 500, err

    parseCookie: (req, key) ->
      return undefined if not req.headers.cookie
      cookie = req.headers.cookie
      console.log cookie
      cookiearr = cookie.split ';'
      console.log cookiearr
      ret = undefined
      _.each cookiearr, (v, k) ->
        console.log v.trim()
        console.log k
        varr = v.trim().split '='
        if varr[0].trim() is key
          ret = varr[1].trim()
      ret

    getPageInfo: (req)->
      _params = req.params
      _index = Math.max(fns.intval(_params.startIndex || _params['start-index']), 1) if _params.startIndex or _params['start-index']
      _max = Math.max(fns.intval(_params.maxResults || _params['max-results']), 0) || 20 if _params.maxResults or _params['max-results']
      [_index - 1, _max]
      

    err: (status, msg)->
      switch status
        when 506
          return new ReportError msg
        when 401
          return new Webnode.Restify.InvalidCredentialsError msg
        when 403
          return new Webnode.Restify.NotAuthorizedError msg
        when 409
          return new Webnode.Restify.InvalidArgumentError msg
        else
          return super

