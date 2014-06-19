var MapView = function() {
  this.map
  this.directionsDisplay = new google.maps.DirectionsRenderer();
  this.directionsService = new google.maps.DirectionsService();
  this.geocoder = new google.maps.Geocoder();
  this.bounds = new google.maps.LatLngBounds();
  this.overlays = { markers: [], paths: [] }
}

MapView.prototype = {
  initialize: function() {
    var sanFran = new google.maps.LatLng(37.7833, -122.4167);
    var mapOptions = {
      zoom:12,
      center: sanFran
    }
    this.map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
    this.directionsDisplay.setMap(this.map);
  },
  resize: function(){
    var otherElementsHeight = 0

    otherElementsHeight += $(".navbar").outerHeight(true)

    if ($(".directions-group").is(":visible")) {
      otherElementsHeight += $(".directions-group").outerHeight(true)
    }

    if ($("#errors").is(":visible")) {
      otherElementsHeight += $("#errors").outerHeight(true)
    }

    if ($(".slider-row").is(":visible")) {
      otherElementsHeight += $(".slider-row").outerHeight(true)
    }

    otherElementsHeight += parseInt($('#map-canvas').css("margin-bottom"))
    var windowHeight = $(window).height()

    var height = windowHeight - otherElementsHeight - 5
    $('#map-canvas').height(height)
  },
  removeOldOverlays: function() {
    this.clearMarkers()
    this.clearPaths()
    this.overlays = { markers: [], paths: [] }
  },
  clearMarkers: function() {
    for (var i = 0; i < this.overlays.markers.length; i ++) {
      this.overlays.markers[i].setMap(null)
    }
  },
  clearPaths: function() {
    for (var i = 0; i < this.overlays.paths.length; i ++) {
      this.overlays.paths[i].setMap(null)
    }
  },
  addMarkerToMap: function(address, coords) {
    var latLon = new google.maps.LatLng(coords.lat, coords.lon);
    var marker = new google.maps.Marker({
        position: latLon,
        map: this.map,
        title: address
    });
    this.overlays.markers.push(marker)
  },
  addPathsToMap: function(paths) {
    for (var i = 0; i < paths.length; i++) {
      this.addPathToMap(paths[i])
    }
    this.showMapPath(0)
  },
  addPathToMap: function(path) {
    var directionCoordinates = [];

    for (var i = 0; i < path.length; i++) {
      latLon = new google.maps.LatLng(path[i][0], path[i][1])
      directionCoordinates.push(latLon)
      this.bounds.extend(latLon)
    }

    var directionPath = new google.maps.Polyline({
      path: directionCoordinates,
      geodesic: true,
      strokeColor: '#FF0000',
      strokeOpacity: 1.0,
      strokeWeight: 2
    });
    this.overlays.paths.push(directionPath)
  },
  reboundMap: function(coords) {
    for (var i = 0; i < coords.length; i++) {
          var latLon = new google.maps.LatLng(coords[i].lat, coords[i].lon)
          this.bounds.extend(latLon)
    }
    this.map.fitBounds(this.bounds)
  },
  showMapPath: function(val) {
    this.clearPaths()
    var path = this.overlays.paths[val]
    path.setMap(this.map)
  }
}