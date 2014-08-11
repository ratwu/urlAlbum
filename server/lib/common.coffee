_ = require 'underscore'
path = require 'path'
db = require './mysqlDao'
moment = require 'moment'
allowCallModelList = ['budget', 'award', 'partner', 'expert', 'project', 'outsourcing', 'project_progress', 'project_reserve', 'project_abroad', 'notice']
dateFilterTables = ['project', 'outsourcing']

relatedUserInfo = (_model) ->
  return {} if not _model or not _model.user_id
  users = db.exec "select * from `user` where id = '#{_model.user_id}'"
  return {} if users.length is 0
  departs = db.exec "select * from `depart` where id = '#{users[0].depart_id}'"
  _model.user_id = users[0].id
  _model.user_account = users[0].account
  _model.depart_id = departs[0].id if departs.length isnt 0
  _model.depart_name = departs[0].name if departs.length isnt 0
  _model

relatedUserInfoForList = (_list) ->
  _returnList = []
  for _model in _list
  	_model = relatedUserInfo(_model)
  	_returnList.push _model
  _returnList

modelList = (_table, _user, _index, _max, _startDate, _endDate, _cond) ->
  _index = 0 #if not _index
  _max = 300 #if not _max
  return [] if _table not in allowCallModelList
  _sql = ""
  _where = []
  _sql = [
    "select u.`account` as 'user', dp.id as 'depart_id', dp.name as 'depart', "
    "p.name as 'project', " if _table in ['project_progress', 'outsourcing', 'award']
    "a.*, date_format(a.createdAt, '%Y-%m-%d') as 'createdAt', date_format(a.updatedAt, '%Y-%m-%d') as 'updatedAt' "
    ",date_format(a.date, '%Y-%m-%d') as 'date'" if _table in ['project', 'outsourcing']
    "from `#{_table}` as a left join `user` as u on a.user_id=u.id "
    "left join `project` as p on a.project_id=p.id" if _table in ['project_progress', 'outsourcing', 'award']
    "left join `depart` as d on d.id = u.depart_id"
    "left join `depart` as dp on dp.id = a.depart_id"].join " "
  _sql += " limit #{_index}, #{_max} " if _index and _max
  _where = [
    "a.depart_id=#{_user.depart_id}" if _user.role is 'user' #如果是角色is用户，只能查看本部门的列表信息
    "a.date >= '#{_startDate}' and a.date <= '#{_endDate}'" if _startDate and _endDate and _table isnt 'project_progress'
    "p.date >= '#{_startDate}' and p.date <= '#{_endDate}'" if _startDate and _endDate and _table is 'project_progress'
  ]
  _like = []
  if _cond
    _.each _cond, (_v, _k) ->
      _like.push "a.`#{_k}` like '%#{_v}%' "
  _like = _like.join " and "
  _where.push _like
  _where = _.without _where, undefined, ''
  console.log _where
  _where = " where " + _where.join(" and ") if _where.length > 0
  _sql += _where
  console.log "modelList sql:#{_sql}"
  db.exec _sql

dashBoard = (_user, _startDate, _endDate) ->
  _sql = ["select count(*) as totalProjects, ifnull(sum(case when `status`='审核中' then 1 else 0 end),0) as 
  'notCheckeds', ifnull(sum(case when `status`='已审核' then 1 else 0 end),0) as 'checkedOks', 
  ifnull(sum(case when `status`='审核未通过' then 1 else 0 end),0) as 'checkedNos' from project "
  ].join " "
  _where = [
    "depart_id = #{_user.depart_id}" if _user.role is 'user'
    "date >= '#{_startDate}' and date <= '#{_endDate}'" if _startDate and _endDate
  ]
  _where = _.reject _where, (_element) ->
    _element is undefined
  if _where isnt []
    _where = _where.join ' and '
    _where = "where " + _where
    _sql = _sql + _where
  console.log "dashBoard sql:#{_sql}"
  db.exec _sql

chart = (_user, _startDate, _endDate) ->
  _year = moment().format("YYYY")
  _sql = ["select date_format(`date`, '%Y-%m') as 'month', count(*) as totalProjects, "
  "ifnull(sum(case when `status`='审核中' then 1 else 0 end),0) as 'notCheckeds', "
  "ifnull(sum(case when `status`='已审核' then 1 else 0 end),0) as 'checkedOks', "
  "ifnull(sum(case when `status`='审核未通过' then 1 else 0 end),0) as 'checkedNos' "
  "from project "
  ].join " "
  _where = [
    "depart_id = #{_user.depart_id}" if _user.role is 'user'
    "date >= '#{_startDate}' and date <= '#{_endDate}'" if _startDate and _endDate
  ]
  _where = _.reject _where, (_element) ->
    _element is undefined
  if _where isnt []
    _where = _where.join ' and '
    _where = " where " + _where
    _sql = _sql + _where
  _sql = _sql + " group by date_format(`date`, '%Y-%m') "
  console.log "chart sql:#{_sql}"
  db.exec _sql

module.exports = {relatedUserInfo, relatedUserInfoForList, modelList, dashBoard, chart}
