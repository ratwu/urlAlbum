Sequelize = require 'sequelize'

module.exports = (sequelize)->
  User = sequelize.define 'user', {
    id: Sequelize.INTEGER
    username:
      type: Sequelize.STRING
      validate:
        notEmpty: true
    uuid: Sequelize.STRING
    email:
      type: Sequelize.STRING
      validate:
        isEmail: true
    userRole:
      type: Sequelize.STRING
      defaultValue: 'user'
    accessToken: Sequelize.STRING
    expired: Sequelize.DATE
  }, {
    freezeTableName: true
    instanceMethods:
      isSuperAdmin: ->
        return !@siteId and @userRole is 'admin'
  }
