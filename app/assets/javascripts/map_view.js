var MapView = function() {
  this.map
  this.directionsDisplay = new google.maps.DirectionsRenderer();
  this.directionsService = new google.maps.DirectionsService();
  this.geocoder = new google.maps.Geocoder();
  this.bounds = new google.maps.LatLngBounds();
  this.overlays = []
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
    var navHeight = $(".navbar").height()
    + parseInt($(".navbar").css("margin-bottom"))
    + parseInt($(".navbar").css("margin-top"))

    var searchHeight = $(".directions-group").height()
    + parseInt($(".directions-group").css("margin-bottom"))
    + parseInt($(".directions-group").css("margin-top"))

    var errorHeight = $("#errors").height()
    + parseInt($("#errors").css("margin-bottom"))
    + parseInt($("#errors").css("margin-top"))

    var sliderHeight = $(".slider-row").height()
    + parseInt($(".slider-row").css("margin-bottom"))
    + parseInt($(".slider-row").css("margin-top"))

    var mapMargin = parseInt($('#map-canvas').css("margin-bottom"))
    var windowHeight = $(window).height()

    var height = windowHeight - navHeight - searchHeight - errorHeight - mapMargin - sliderHeight - 5

    $('#map-canvas').height( height );
  },
  removeOldOverlays: function() {
    this.clearMapOverlays()
    this.overlays = []
  },
  clearMapOverlays: function() {
    for (var i = 0; i < this.overlays.length; i ++) {
      this.overlays[i].setMap(null)
    }
  },
  addMarkerToMap: function(address, coords) {
    var latLon = new google.maps.LatLng(coords.lat, coords.lon);
    var marker = new google.maps.Marker({
        position: latLon,
        map: this.map,
        title: address
    });
    this.overlays.push(marker)
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
    directionPath.setMap(this.map);
    this.overlays.push(directionPath)
  },
  reboundMap: function(coords) {
    for (var i = 0; i < coords.length; i++) {
          var latLon = new google.maps.LatLng(coords[i].lat, coords[i].lon)
          this.bounds.extend(latLon)
    }
    this.map.fitBounds(this.bounds)
  }
}