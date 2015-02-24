class IndusService
  constructor: (@$scope, @$http, @url = "http://192.168.1.38:4000/v1") ->

  createStream: () ->
    return @$http.post "#{@url}/data/"

  insertDatapoint: (stream_uuid, data) ->
    fd = new FormData()
    fd.append('data', new Blob([JSON.stringify(data)],{type: "application/json"}))

    return @$http.post "#{@url}/data/#{stream_uuid}", fd,
      transformRequest: angular.identity,
      headers: {'Content-Type': undefined}

  getLatestDatapoint: (stream_uuid) ->
    return @$http.get "#{@url}/data/#{stream_uuid}/latest"
