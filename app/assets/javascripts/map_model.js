var MapModel = function(startPoint, endPoint) {
  this.startPoint = startPoint;
  this.endPoint = endPoint;
  this.possibleWaypoints
  this.startPosition
  this.endPosition
}

MapModel.prototype = {
  convertEndpointsToLatLong: function() {
    this.startPosition = this.getLatLang(this.startPoint);
    this.endPosition = this.getLatLang(this.endPoint);
  },
  getLatLang: function(address) {
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode( { 'address': address}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        console.log(results[0].geometry.location)
        return results[0].geometry.location
      } else {
        console.log("There was a problem with one or more of your endpoints")
        // TODO: handle this edge case
      }
    });
  },
  generatePossibleWaypoints: function() {
    var generator = new WaypointGenerator()
    this.possibleWaypoints = generator.start(this.startPosition, this.endPosition)
  }
}