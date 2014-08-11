Sequelize   = require 'sequelize'

module.exports = (app) ->
  dict = {}
  for db in app.getConfig().dbs
    dict[db.key] = new Sequelize db.db_name, db.user || 'root', db.passwd || null,
      host: db.host || 'localhost'
      port: db.port || '3306'
      pool:
        maxConnections: db.max_connections || 10
        maxIdleTime: db.max_idle_time || 30
        minConnections: db.min_connections || 2
      define:
        charset: db.charset || 'utf8'
        collate: db.collate || 'utf8_general_ci'
  dict

