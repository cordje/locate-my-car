
setHeights = () ->
  leaflet = $(".angular-leaflet-map")
  leaflet.css("height","#{$(window).height()}")
  leaflet.css("width","#{$(window).width()}")

$(window).on "orientationchange resize", setHeights

app = angular.module("locateapp", ["leaflet-directive", "ui.bootstrap"])

app.controller "CarLocationMapController", ($scope, $modal, $log, $http) ->
  angular.extend $scope, {
    center: {
      autoDiscover: true
    },
    markers: new Array()
  }

  $scope.controls = {
    custom: []
  }

  #Set Car Control
  SetCarControl = L.control()
  SetCarControl.setPosition('topright')
  SetCarControl.onAdd = () ->
    className = 'leaflet-control-set-car'
    control = L.DomUtil.create('span', className + ' fa fa-car fa-3x')
    control.setAttribute("ng-click","openSetCarModal()")
    control.setAttribute("tooltip", "Set Car To Park")
    L.DomEvent.on(control, 'mousedown dblclick', L.DomEvent.stopPropagation)
      .on(control, 'click', L.DomEvent.stop)
      .on(control, 'click', $scope.openSetCarModal, $scope)
    return control

  $scope.controls.custom.push(SetCarControl)

  #Center On Last Location Control
  CenterOnLastControl = L.control()
  CenterOnLastControl.setPosition('topright')
  CenterOnLastControl.onAdd = () ->
    className = 'leaflet-control-center-on-last'
    control = L.DomUtil.create('div', className + ' fa fa-location-arrow fa-4x')
    L.DomEvent.on(control, 'mousedown dblclick', L.DomEvent.stopPropagation)
      .on(control, 'click', L.DomEvent.stop)
      .on(control, 'click', $scope.centerOnCurrentLocation, $scope)
    return control

  $scope.controls.custom.push(CenterOnLastControl)

  $scope.indus = new IndusService($scope, $http, "http://indus-service.herokuapp.com/v1")

  $scope.$watch 'streamUuid', (newValue, oldValue) ->
    if newValue?.length > 0
      $scope.indus.getLatestDatapoint(newValue).then (response) ->
        return if response.data == "null"
        data = JSON.parse(response.data.data)
        $scope.markers.push data.location
      , (failure) ->
        if not $scope.streamUuid?
          $scope.openSetCarModal()

  $scope.state = window.localStorage.getItem("state")
  $scope.licensePlate = window.localStorage.getItem("licensePlate")
  $scope.streamUuid = window.localStorage.getItem("streamUuid")

  $scope.centerOnCurrentLocation = () ->
    if not $scope.streamUuid? or $scope.markers.length == 0
      alert("No current location available! Either stream uuid is invalid or there are no previous places logged.")

    $scope.center =
      lat: $scope.markers[0].lat
      lng: $scope.markers[0].lng
      zoom: 18

  $scope.openSetCarModal = (size) ->
    modalInstance = $modal.open {
      templateUrl: 'setCarModal.html'
      controller: 'SetCarModalController'
      size: size
      resolve:
        state: () ->
          return $scope.state
        licensePlate: () ->
          return $scope.licensePlate
        streamUuid: () ->
          return $scope.streamUuid
    }

    selectedItemSet = (options) ->
      $scope.state = options.state
      if $scope.state?.length == 0 or typeof($scope.state) == "undefined"
        window.localStorage.removeItem("state")
        $scope.state = null
      else
        window.localStorage.setItem("state", $scope.state)

      $scope.licensePlate = options.licensePlate
      if $scope.licensePlate?.length == 0 or typeof($scope.licensePlate) == "undefined"
        window.localStorage.removeItem("licensePlate")
        $scope.licensePlate = null
      else
        window.localStorage.setItem("licensePlate", $scope.licensePlate)

      $scope.streamUuid = options.streamUuid
      if $scope.streamUuid?.length == 0 or typeof($scope.streamUuid) == "undefined"
        window.localStorage.removeItem("streamUuid")
        $scope.streamUuid = null
      else
        window.localStorage.setItem("streamUuid", $scope.streamUuid)

      if not $scope.streamUuid? or $scope.streamUuid?.length == 0
        $scope.indus.createStream().then (data) ->
          $scope.streamUuid = data.data.uuid
          if $scope.streamUuid?.length == 0 or typeof($scope.streamUuid) == "undefined"
            window.localStorage.removeItem("streamUuid")
            $scope.streamUuid = null
          else
            window.localStorage.setItem("streamUuid", $scope.streamUuid)

    logDismissal = () ->
      $log.info("Modal dismissed at: #{new Date()}")

    modalInstance.result.then selectedItemSet, logDismissal

  $scope.$on "leafletDirectiveMap.click", (evt, args) ->
    if not $scope.streamUuid?
      $scope.openSetCarModal()

    leafEvent = args.leafletEvent

    newCarLocation =
      lat: leafEvent.latlng.lat
      lng: leafEvent.latlng.lng

    $scope.markers.push newCarLocation

    modalInstance = $modal.open {
      templateUrl: 'confirmCarLocation.html'
      controller: 'ConfirmCarLocationModalController'
      size: 'sm'
      resolve: {}
    }

    setLocation = (options) ->
      $scope.markers = [newCarLocation]
      $scope.indus.insertDatapoint $scope.streamUuid,
        status: "parked"
        car:
          license_plate: $scope.licensePlate
          state: $scope.state
        location: newCarLocation

    removeMarker = () ->
      index = $scope.markers.indexOf(newCarLocation)
      $scope.markers.splice(index,1)

    modalInstance.result.then setLocation, removeMarker

  setHeights()

app.controller "SetCarModalController", ($scope, $modalInstance, state, licensePlate, streamUuid) ->
  $scope.states = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Dakota', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming']
  $scope.state = state
  $scope.licensePlate = licensePlate
  $scope.streamUuid = streamUuid

  $scope.$watch 'state', (newValue, oldValue) ->
    if newValue != oldValue
      $scope.streamUuid = null

  $scope.$watch 'licensePlate', (newValue, oldValue) ->
    if newValue != oldValue
      $scope.streamUuid = null

  $scope.ok = () ->
    $modalInstance.close
      state: $scope.state
      licensePlate: $scope.licensePlate
      streamUuid: $scope.streamUuid

  $scope.cancel = () ->
    $modalInstance.dismiss('cancel')

app.controller "ConfirmCarLocationModalController", ($scope, $modalInstance) ->

  $scope.setLocation = () ->
    $modalInstance.close()

  $scope.cancel = () ->
    $modalInstance.dismiss('cancel')
