_ = require 'underscore'
mysql = require 'mysql-libmysqlclient'
mysqlConf = require('../config/development/config').mysql

conn = null
connect = ->
  conn = mysql.createConnectionSync mysqlConf.host, mysqlConf.user, mysqlConf.passwd
  if not conn.connectedSync()
    throw Error "Error: #{conn.connectError} Errno: #{conn.connectErrno}"
  conn.setOptionSync mysql.MYSQL_OPT_RECONNECT, 1
  if not conn.selectDbSync mysqlConf.db_name
    throw Error "Error: #{conn.connectError} Errno: #{conn.connectErrno}"
  conn.setCharsetSync 'utf8'
connect()

addslashes = (str) ->
  return str if _.isNumber str
  return "" if not _.isString str
  str = str.replace /\\/g, '\\\\'
  str = str.replace /\'/g, '\\\''
  str = str.replace /\"/g, '\\"'
  str = str.replace /\0/g, '\\0'

exec = (_sql) ->
  _query = conn.querySync _sql
  _query.fetchAllSync()

insert = (_conf, _data) ->
  return if _.isEmpty _data
  _table = _conf.table
  _cols = _conf.cols
  _sql = "INSERT INTO #{_table} (#{_.map(_cols, (_x) -> "`#{_x}`").join(',')}) VALUES "
  _values = _.map(_data, (_row) ->
    "(#{_.map(_cols, (x)-> "'#{addslashes(_row[x])}'").join(',')})"
  ).join(',')
  _sql = "#{_sql}#{_values}"
  console.log _sql
  _query = conn.querySync _sql
  conn.affectedRowsSync()

update = (_conf, _data) ->
  return if _.isEmpty _data
  _table = _conf.table
  _where = _conf.where
  _set = _.map(_data, (_value, _key) -> "`#{_key}`='#{addslashes(_value)}'").join(',')
  _sql = "UPDATE #{_table} SET #{_set} WHERE #{_where};"
  console.log _sql
  _query = conn.querySync _sql
  conn.affectedRowsSync()

del = (_conf) ->
  _table = _conf.table
  _where = _conf.where
  _sql = "DELETE FROM #{_table} WHERE #{_where}"
  _query = conn.querySync _sql
  conn.affectedRowsSync()

module.exports = {exec, insert, update, del}
