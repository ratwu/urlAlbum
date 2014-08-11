Webnode = require 'webnode'
_       = require 'underscore'
fns     = require '../../lib/fns'
moment = require 'moment'

module.exports = (app)->
  # API基础控制器
  APIController = require('../../lib/api_controller')(app)

  # 加载model
  User = app.model 'user'
  Depart = app.model 'depart'

  class UserController extends APIController
    # 公共API
    public: ['login']

    # 获取资源列表
    index: (req, res)->
      @checkAuth 'manager'
      # 分页
      # User.count().success (_count)=>
      #   [_index, _max] = @getPageInfo(req)
      #   User.findAll(
      #     order: 'id DESC'
      #     attributes: 'id,account,role,createdAt,updatedAt'.split ','
      #     limit : _index
      #     offset: _max
      #   ).success (_list)=>
      #     res.header "X-Content-Record-Total", _count
      #     res.send 200, _list
      User.userList @user, (_list) ->
        res.send 200, _list

    # 创建资源
    create: (req, res)->
      @checkAuth 'manager'
      _data = _.pick req.params, 'account', 'passwd', "role", "depart_id"
      _data.passwd = fns.md5 _data.passwd if _data.passwd
      if @user.role in ['admin', 'manager']
        # throw @err 401, '您无权限新建超级管理员' if not (_data.role in ['admin', 'user'])
        _data.role = 'user'
        _data.depart_id = @user.depart_id 
      _user = User.build(_data)
      _errors = _user.validate()
      throw @err 500, JSON.stringify(_errors) if _errors
      User.find(
          where:
            account: _data.account
        ).success (_exist)=>
          throw @err 409, '用户id已存在' if _exist
          _user.save().success (_model)=>
            res.send 201, fns.cModel _model  

    # 替换资源
    put: (req, res)->
      @checkAuth 'manager'
      User.find(req.params.id).success (_user)=>
        throw @err 404, 'Not found' if not _user
        for _attr in ['account', 'role', 'depart_id'] when req.JSON[_attr]?
          _user[_attr] = req.JSON[_attr]
        _user['passwd'] = fns.md5 req.JSON['passwd'] if req.JSON['passwd'] and req.JSON['passwd'] isnt ''
        _errors = _user.validate()
        throw @err 500, JSON.stringify(_errors) if _errors
        User.find(
          where:
            account: _user.account
        ).success (_exist)=>
          throw @err 409, '用户id已存在' if _exist and _exist.id isnt parseInt req.params.id
          _user.save().success (_model)=>
            res.send 201, fns.cModel _model

    # 更新资源
    patch: (req, res)->
      @put req, res

    # 获取指定资源
    get: (req, res)->
      @checkAuth 'manager'
      # User.find(req.params.id).success (_model)=>
      #   throw @err 404, 'Not found' if not _model
      #   res.send _model
      User.userInfo req.params.id, (_user) ->
        throw @err 404, 'Not found' if not _user or _user.length is 0 or _user.length > 1
        res.send _user[0]

    # 删除指定资源
    delete: (req, res)->
      res.send 403, "Forbidden"

    # 当前登录用户的用户信息
    session: (req, res)->
      res.send 200, @user

    login: (req, res) ->
      throw @err 401, '您没有权限操作此项' if not req.params.account or not req.params.passwd
      User.find(
          where:
            account: req.params.account
            passwd: fns.md5 req.params.passwd
        ).success (_user) =>
          throw @err 401, '您没有权限操作此项' if not _user
          _random = new Number(Math.random() * 1000000).toFixed(0)
          _date = new Date()
          _date.setMinutes(_date.getMinutes() + 30)
          _expires = _date.toGMTString()
          _accessToken= ""
          if not _user.access_token or not _user.updatedAt or moment().subtract("hours", 8).format("YYYYMMDDHH") - moment(_user.updatedAt).format("YYYYMMDDHH") > 2
            _accessToken = fns.md5 req.params.account+req.params.passwd+_random
            _user.access_token = _accessToken
          else
            _accessToken = _user.access_token
          _user.save().success (_model)=>
            Depart.find(
                where:
                  id: _user.depart_id
              ).success (_depart) =>
                res.header("Set-Cookie", "_centerAuth=#{_accessToken};expires=#{_expires};path=/")
                _return = _.pick _user, "account", "role", "id", 'depart_id'
                _return.cookie = _accessToken
                _return.depart_name = _depart.name
                _return.depart_number = _depart.number
                res.send 200, _return

    userProject: (req, res)->
      @checkAuth 'user'
      User.userProject @user.id, (_result) ->
        res.send _result

    password: (req, res) ->
      @checkAuth 'user'
      _data = _.pick req.params, 'old_pass', 'new_pass', 'new_pass_repeat'
      if not _data.new_pass or not _data.new_pass_repeat or not _data.old_pass
        res.send 409, "密码为空"
      else if _data.new_pass isnt _data.new_pass_repeat
        res.send 409, "两次密码不一致"
      else
        User.find(
          where:
            id: @user.id
            passwd: fns.md5 _data.old_pass
        ).success (_user) =>
          throw @err 401, '您没有权限操作此项' if not _user
          _user.passwd = fns.md5 _data.new_pass
          _user.save().success (_model)=>
            res.send 201, "修改密码成功"
