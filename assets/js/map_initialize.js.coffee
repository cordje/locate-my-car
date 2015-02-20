
setHeights = () ->
  leaflet = $(".angular-leaflet-map")
  leaflet.css("height","#{$(window).height()}")
  leaflet.css("width","#{$(window).width()}")

$(window).on "orientationchange resize", setHeights

app = angular.module("locateapp", ["leaflet-directive"])

app.controller "CarLocationMapController", [ '$scope', ($scope) ->
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

  SetCarControl = L.control()
  SetCarControl.setPosition('topright')
  SetCarControl.onAdd = () ->
    className = 'leaflet-control-set-car'
    control = L.DomUtil.create('span', className + ' fa fa-car fa-3x')
    control.setAttribute('data-toggle','modal')
    control.setAttribute('data-target','#set-car-modal')
    L.DomEvent.on(control, 'mousedown dblclick', L.DomEvent.stopPropagation)
      .on(control, 'click', L.DomEvent.stop)
    return control

  $scope.controls.custom.push(SetCarControl)

  CenterOnLastControl = L.control()
  CenterOnLastControl.setPosition('topright')
  CenterOnLastControl.onAdd = () ->
    className = 'leaflet-control-center-on-last'
    container = L.DomUtil.create('div', className + ' fa fa-plus fa-4x')
    return container

  $scope.controls.custom.push(CenterOnLastControl)

  setHeights()
]

