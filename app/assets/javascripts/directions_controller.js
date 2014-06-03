var DirectionsController = function(view, model){
  this.view = view
  this.model = model
  this.possibleWaypoints
  this.fakeStart = {k: 37.794807, A: -122.41799409999999}
  this.fakeEnd = {k: 37.7846334, A: -122.39741370000002}
  this.directionsService = new google.maps.DirectionsService();
  this.possibleDirections = []
}

DirectionsController.prototype = {
  generateEndpointLatLong: function() {
    this.model.convertEndpointsToLatLong();
  },
  generatePossibleDirections: function() {
    var generator = new WaypointGenerator(this.fakeStart, this.fakeEnd)
    this.possibleWaypoints = generator.start()
    for (var i = 0; i < this.possibleWaypoints.length; i++) {
      this.generateRoute(this.fakeStart, this.fakeEnd, this.possibleWaypoints[i]);
    }
  },
  generateRoute: function(startPoint, endPoint, waypoint) {
    waypts = []
    waypts.push({location: new google.maps.LatLng(waypoint.k, waypoint.A)})
    
    var request = {
      origin: new google.maps.LatLng(startPoint.k, startPoint.A),
      destination: new google.maps.LatLng(endPoint.k, endPoint.A),
      waypoints: waypts,
      travelMode: google.maps.TravelMode.WALKING
    };

    var response = this.directionsService.route(request, function(response, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        this.possibleDirections.push(response)
      }
    }.bind(this));
  }
}