var MapModel = function(startPoint, endPoint) {
  this.startPoint = startPoint;
  this.endPoint = endPoint;
  this.startCoords
  this.endCoords
  this.convertEndpointsToLatLong();
}

MapModel.prototype = {
  convertEndpointsToLatLong: function() {
    this.startCoords = this.getLatLang(this.startPoint);
    this.endCoords = this.getLatLang(this.endPoint);
  },

  getLatLang: function(address) {
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode( { 'address': address}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        return results[0].geometry.location
      } else {
        console.log("There was a problem with one or more of your endpoints")
      }
    });
  }
}