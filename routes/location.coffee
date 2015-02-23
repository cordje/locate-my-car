exports.getLocation = (req,res) ->
  facebookUserId = req.query.facebook_user_id
  db.User.find({ where: {facebook_user_id: facebookUserId} }).complete (err, user) ->
    if !!err
      res.status(500).send("Database error on User lookup")
    else if !user
      res.status(404).send("User not found")
    else
      carToLookup =
        state: req.params.state
        license_plate: req.params.license_plate
      db.Car.find({ where: carToLookup }).complete (err, car) ->
        if err?
          return res.status(500).end("Database error on Car lookup")
        else if car?
          db.Location.findAll({where: { CarId: car.id }, limit: 1, order: 'timestamp DESC'}).complete (err, locations) ->
            console.log(JSON.stringify(locations[0]))
            res.json(locations[0])
        else
          return res.status(404).end("No car found")

exports.setLocation = (req,res) ->
  facebookUserId = req.query.facebook_user_id
  lat = req.query.lat
  lng = req.query.lng

  return res.status(400).end("Missing query string parameters") if not facebookUserId? or not lat? or not lng?

  db.User.findOrCreate({facebook_user_id: facebookUserId}).complete (err, user) ->
    res.status(500).end("Database error on User lookup/creation") if err?
    carToLookupOrCreate =
      UserId: user.id
      state: req.params.state
      license_plate: req.params.license_plate

    db.Car.findOrCreate(carToLookupOrCreate).complete (err, car) ->
      res.status(500).end("Database error on Car lookup/creation") if err?
      db.Location.findOrCreate({latitude: lat, longitude: lng, timestamp: new Date(), CarId: car.id}).complete (err, location) ->
        res.status(500).end("Database error on Location lookup/creation") if err?
        res.json(location)

