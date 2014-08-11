Request = require 'request'

module.exports = (app)->
  return {
    getUser: (token, cb)->
      console.log "uri:#{app.getConfig().open_master_url + '/user?access_token=' + token}"
      Request {
        uri: app.getConfig().open_master_url + '/user?access_token=' + token
        timeout: 30000
        }, (err, res, body)->
        # throw Error('无效的Open账户') if err or res.statusCode isnt 200
        return cb err, null if err or res.statusCode isnt 200
        open_user = JSON.parse body
        cb null, open_user

  authorize: (loginName, passwd, next)->
    Request.post(app.getConfig().open_master_url + '/oauth/access_token', {
      form:
        client_id: app.getConfig().client_id,
        client_secret: app.getConfig().client_secret,
        grant_type: 'password',
        email: loginName,
        password: passwd
    }, (err, res, body) ->
      return next err, null if err or res.statusCode isnt 200
      next null, JSON.parse body
    )
  }
