module.exports = (sequelize, DataTypes) ->
  return sequelize.define "User", {
    facebook_user_id: DataTypes.INTEGER
  }, {
    instanceMethods: {
    }
  }
