var DirectionsController = function(view, model){
  this.view = view
  this.model = model
  this.possibleWaypoints
  this.fakeStart = {k: 37.794807, A: -122.41799409999999}
  this.fakeEnd = {k: 37.7846334, A: -122.39741370000002}
  this.directionsService = new google.maps.DirectionsService();
  this.possibleDirections = []
  this.map
  this.initialize()
}

DirectionsController.prototype = {
  generateEndpointLatLong: function(callbackObj, callbackFunc) {
    this.model.convertEndpointsToLatLong(callbackObj, callbackFunc);
  },
  generatePossibleDirections: function() {
    // var generator = new WaypointGenerator(this.fakeStart, this.fakeEnd)
    var generator = new WaypointGenerator(this.model.startPosition, this.model.endPosition)
    this.possibleWaypoints = generator.start()
    for (var i = 0; i < this.possibleWaypoints.length; i++) {
      // this.generateRoute(this.fakeStart, this.fakeEnd, this.possibleWaypoints[i]);
      this.generateRoute(this.model.startPosition, this.model.endPosition, this.possibleWaypoints[i]);
    }
  },
  generateRoute: function(startPoint, endPoint, waypoint) {
    var waypts = []
    waypts.push({location: new google.maps.LatLng(waypoint.k, waypoint.A),
      stopover: false})

    var request = {
      origin: new google.maps.LatLng(startPoint.k, startPoint.A),
      destination: new google.maps.LatLng(endPoint.k, endPoint.A),
      waypoints: waypts,
      travelMode: google.maps.TravelMode.WALKING
    };

    var directionsDisplay = new google.maps.DirectionsRenderer();
    directionsDisplay.setMap(this.map);
    this.directionsService.route(request, function(response, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        this.possibleDirections.push(response)
        directionsDisplay.setDirections(response);
      }
    }.bind(this));
  },
  initialize: function() {
    var sanFran = new google.maps.LatLng(37.7833, -122.4167);
    var mapOptions = {
      zoom:7,
      center: sanFran
    }
    this.map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
  }
}