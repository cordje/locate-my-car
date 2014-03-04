url = require 'url'

unless global.hasOwnProperty("db")
  Sequelize = require("sequelize")
  sequelize = null

  if process.env.DATABASE_URL?
    dbUrl   = url.parse(process.env.DATABASE_URL)
    authArr = dbUrl.auth.split(':')
    console.log authArr
    console.log dbUrl.host
    console.log dbUrl.path
  dbOptions = switch process.env.NODE_ENV
    when 'production'
      name: dbUrl.path.substring(1)
      user: authArr[0]
      pass: authArr[1]
      host: dbUrl.host
      port: null
      dialect: 'postgres'
      protocol: 'postgres'
    when 'development'
      name: 'locate-my-car-test'
      user: 'locate-my-car'
      pass: 'test'
      host: '127.0.0.1'
      port: null
      dialect: 'postgres'
      protocol: 'postgres'

  sequelize = new Sequelize(dbOptions.name, dbOptions.user, dbOptions.pass, {
    host: dbOptions.host,
    port: dbOptions.port,
    dialect: dbOptions.dialect,
    protocol: dbOptions.protocol,
    logging: true #false
  } )

  global.db =
    Sequelize: Sequelize
    sequelize: sequelize
    User: sequelize.import(__dirname + "/user")
    Car: sequelize.import(__dirname + "/car")
    Location: sequelize.import(__dirname + "/location")
    # add your other models here

  global.db.User.hasMany(global.db.Car)
  global.db.Car.hasMany(global.db.Location)

module.exports = global.db
