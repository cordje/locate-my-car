exports.index = (req, res) ->
  res.render 'index', { title: 'Locate My Car' }

exports.location = require './location'
