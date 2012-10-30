var connection_string_regex = /^postgres:\/\/([a-z\-]+):([a-zA-Z0-9]+)@([a-z0-9\-\.]+):([0-9]*)\/([a-z0-9]+)/;
var connection_parts = process.env.DATABASE_URL.match(connection_string_regex);

var database_username = connection_parts[1],
    database_password = connection_parts[2],
    database_hostname = connection_parts[3],
    database_port = connection_parts[4],
    database_name = connection_parts[5]; 

var Sequelize = require("sequelize");

// All options at once:
var sequelize = new Sequelize(database_name, database_username, database_password, {
  // custom host; default: localhost
  host: database_hostname,
 
  // custom port; default: 3306
  port: database_port,
 
  // custom protocol
  // - default: 'tcp'
  // - added in: v1.5.0
  // - postgres only, useful for heroku
  protocol: 'postgresql',
 
  // disable logging; default: console.log
  logging: false,
 
  // max concurrent database requests; default: 50
  maxConcurrentQueries: 100,
 
  // the sql dialect of the database
  // - default is 'mysql'
  // - currently supported: 'mysql', 'sqlite', 'postgres'
  dialect: 'postgres',
 
  // disable inserting undefined values as NULL
  // - default: false
  omitNull: true,
 
  // specify options, which are used when sequelize.define is called
  // the following example is basically the same as:
  // sequelize.define(name, attributes, { timestamps: false })
  // so defining the timestamps for each model will be not necessary
  define: { timestamps: false },
 
  // use pooling in order to reduce db connection overload and to increase speed
  // currently only for mysql and postgresql (since v1.5.0)
  pool: { maxConnections: 5, maxIdleTime: 30}
});

exports.sequelize = sequelize;

var models = {
  User : sequelize.define('User', {
    vegetarian: { 'type': Sequelize.BOOLEAN , 'defaultValue': true }
  }, {
    instanceMethods: {
      getCars: function(onFind) {
        models.Car.findAll({where : { UserId : req.session.auth.id }} ).success(function(locations) {
          console.log("Location Found: " + locations[0]);
          onFind(locations[0]);
        }).error( function(error) {
          console.log("Error in Car Finding: " + error);
          onFind({}); 
        });
      },
      getCar: function(onFind) {
        this.getCars(function(cars) {
          if(cars.length > 0) {
            onFind(cars[0]); 
          } else {
            onFind();
          }
        });
      },
    }
  }),
  FacebookUser: sequelize.define('FacebookUser', {
    facebook_id: Sequelize.INTEGER,
    name: Sequelize.STRING,
    first_name: Sequelize.STRING,
    last_name: Sequelize.STRING,
  }),
  Car: sequelize.define('Car', {
    make: Sequelize.STRING,
    model: Sequelize.STRING,
  }, {
    instanceMethods: {
      getLocations: function(onFind) {
        models.Location.findAll().success(function(locations) {
          console.log("Location Found: " + locations[0]);
          onFind(locations[0]);
        });
      },
      getLastLocation: function() {
      },
    }
  }),
  Location: sequelize.define('Location', {
    latitude: Sequelize.FLOAT,
    longitude: Sequelize.FLOAT,
    cross_streets: Sequelize.STRING
  }),
};

models.FacebookUser.belongsTo(models.User);
models.User.hasMany(models.Car, { as : 'Cars' } );
models.Car.hasMany(models.Location);

sequelize.sync()
  .success(function() {})
  .error(function() {});

exports.models = models;
