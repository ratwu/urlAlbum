Sequelize = require 'sequelize'

module.exports = (sequelize)->
  User = sequelize.define 'website', {
    id: Sequelize.INTEGER
    uid:
      type: Sequelize.INTEGER
    title:
      type: Sequelize.STRING
    url:
      type: Sequelize.STRING
    description:
      type: Sequelize.STRING
    category:
      type: Sequelize.STRING
  }, {
    freezeTableName: true
    classMethods:
      userInfo: (_userId, _cb) ->
        _sql = [
          "select u.id, u.depart_id, u.passwd, u.`account` as 'user', u.`role` as 'user_role', d.name, d.description from `user` as u inner join `depart` as d "
          "on u.depart_id = d.id"
          "where u.id=#{_userId}"
          ].join(" ")
        sequelize.query(_sql).success(_cb).error (_err) ->
          throw _err
  }
