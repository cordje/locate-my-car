module.exports = (sequelize, DataTypes) ->
  return sequelize.define "Car", {
    make: DataTypes.STRING,
    model: DataTypes.STRING,
    year: DataTypes.INTEGER,
    state: DataTypes.STRING,
    license_plate: DataTypes.STRING
  }, {
    instanceMethods: {


    }
  }

