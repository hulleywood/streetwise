var MapModel = function(startPoint, endPoint) {
  this.startPoint = startPoint;
  this.endPoint = endPoint;
  this.possibleWaypoints
  this.startPosition
  this.endPosition
}

MapModel.prototype = {
  convertEndpointsToLatLong: function(callbackObj, callbackFunc) {
    this.getLatLong(this.startPoint, "start");
    this.getLatLong(this.endPoint, "end");
    setTimeout(function() {
    callbackFunc.call(callbackObj);      
    }, 3000)
  },
  getLatLong: function(address, endPoint) {
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode( { 'address': address}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        // console.log(results[0].geometry.location)
        if (endPoint === "start") {
          this.startPosition = results[0].geometry.location
        }
        else {
          this.endPosition = results[0].geometry.location
        }
      } else {
        console.log("There was a problem with one or more of your endpoints")
        // TODO: handle this edge case
      }
    }.bind(this));
  },
  generatePossibleWaypoints: function() {
    var generator = new WaypointGenerator()
    this.possibleWaypoints = generator.start(this.startPosition, this.endPosition)
  }
}