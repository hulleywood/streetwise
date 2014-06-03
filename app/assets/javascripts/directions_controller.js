var DirectionsController = function(view, model){
  this.view = view
  this.model = model
  this.possibleWaypoints
  this.fakeStart = {k: 37.794807, A: -122.41799409999999}
  this.fakeEnd = {k: 37.7846334, A: -122.39741370000002}
}

DirectionsController.prototype = {
  generateEndpointLatLong: function() {
    this.model.convertEndpointsToLatLong();
  },
  generateDirections: function() {
    var generator = new WaypointGenerator(this.fakeStart, this.fakeEnd)
    this.possibleWaypoints = generator.start()
  }
}