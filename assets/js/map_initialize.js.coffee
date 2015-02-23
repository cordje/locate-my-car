
setHeights = () ->
  leaflet = $(".angular-leaflet-map")
  leaflet.css("height","#{$(window).height()}")
  leaflet.css("width","#{$(window).width()}")

$(window).on "orientationchange resize", setHeights

app = angular.module("locateapp", ["leaflet-directive", "ui.bootstrap"])

app.controller "CarLocationMapController", ($scope, $modal, $log) ->
  angular.extend $scope, {
    center: {
      autoDiscover: true
    },
    markers: new Array()
  }

  $scope.controls = {
    custom: []
  }

  displaySetCarPopup = (evt) ->
    console.log("Displaying Set Car Popup")

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
    container = L.DomUtil.create('div', className + ' fa fa-location-arrow fa-4x')
    return container

  $scope.controls.custom.push(CenterOnLastControl)

  $scope.getLastLocation = ($scope) ->
    return $http.get "/car/#{$scope.state}/#{$scope.licensePlate}/location", {}

  $scope.setLastLocation = ($scope, location) ->
    return $http.put "/car/#{$scope.state}/#{$scope.licensePlate}/location", location

  $scope.state = window.localStorage.getItem("state")
  $scope.licensePlate = window.localStorage.getItem("licensePlate")

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
    }

    selectedItemSet = (options) ->
      $scope.state = options.state
      window.localStorage.setItem("state", $scope.state)

      $scope.licensePlate = options.licensePlate
      window.localStorage.setItem("licensePlate", $scope.licensePlate)

    logDismissal = () ->
      $log.info("Modal dismissed at: #{new Date()}")

    modalInstance.result.then selectedItemSet, logDismissal

  setHeights()

app.controller "SetCarModalController", ($scope, $modalInstance, state, licensePlate) ->
  $scope.states = ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Dakota', 'North Carolina', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming']
  $scope.currentState = state
  $scope.licensePlate = licensePlate

  $scope.ok = () ->
    $modalInstance.close
      state: $scope.state
      licensePlate: $scope.licensePlate

  $scope.cancel = () ->
    $modalInstance.dismiss('cancel')
