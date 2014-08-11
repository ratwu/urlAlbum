commander = require 'commander'
crypto = require 'crypto'
_ = require 'underscore'
path = require 'path'
moment = require 'moment'

intval = (_num, _model = 10) ->
  parseInt(_num, _model) || 0

md5 = (_content) ->
  crypto.createHash('md5').update(_content).digest('hex');

upload= (req, res)->
  throw @err 409, "未上传任何文件" if _.isEmpty req.files
  _size = req.files.file.size
  _basename = path.basename req.files.file.path
  _name = path.extname req.files.file.name
  fs.renameSync req.files.file.path, path.join(uploadDir, _basename)
  {'size': _size, 'name': _name}

cModel = (_model) ->
  _model.date = dateFormat _model.date if _model.date
  _model.start_date = dateFormat _model.start_date if _model.start_date 
  _model.end_date = dateFormat _model.end_date if _model.end_date 
  _model.createdAt = dateFormat _model.createdAt if _model.createdAt 
  _model.updatedAt = dateFormat _model.updatedAt if _model.updatedAt
  _model


dateFormat = (_date, _format = 'YYYY-MM-DD') ->
  moment(_date).format(_format)

hash = (_str) ->
  _random = new Number(Math.random() * 1000000).toFixed(0)
  md5 _str + _random

module.exports = {intval, md5, upload, hash, dateFormat, cModel}
