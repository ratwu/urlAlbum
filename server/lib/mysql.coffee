env = process.env._ENVCENTER || 'development'

conf =
  development:
    host: '127.0.0.1'
    user: 'root'
    pass: 'k42030344'
    name: 'center'
  
module.exports = conf[env]
  
