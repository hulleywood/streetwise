var SearchController = function() {
  this.map
  this.directionsDisplay = new google.maps.DirectionsRenderer();
  this.directionsService = new google.maps.DirectionsService();
  this.initialize()
}

SearchController.prototype = {
  initialize: function() {
    var sanFran = new google.maps.LatLng(37.7833, -122.4167);
    var mapOptions = {
      zoom:12,
      center: sanFran
    }
    this.map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
    this.directionsDisplay.setMap(this.map);
  },
  initiateDirectionSearch: function(e) {
    e.preventDefault();
    var form = $('form#directions')[0]
    var ajaxRequest = $.ajax({
      context: this,
      url: form.action,
      type: form.method,
      data: $(form).serialize()
    })

    ajaxRequest.done(this.showDirections)
    ajaxRequest.fail(this.showErrorMessage)
  },
  showDirections: function(response) {
    console.log(response)
    var waypts = []
    var origin = response.routes[0].legs[0].start_address
    var destination = response.routes[0].legs[0].end_address
    waypts.push({location: new google.maps.LatLng(response.routes[0].legs[0].via_waypoint[0].location.lat, response.routes[0].legs[0].via_waypoint[0].location.lng), stopover: false })
    var request = {
      origin: origin,
      destination: destination,
      waypoints: waypts,
      travelMode: google.maps.TravelMode.WALKING
    }
    this.directionsService.route(request, function(
      response, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        this.directionsDisplay.setDirections(response);
      }
    }.bind(this));
    // this.directionsDisplay.setDirections(response);
  },
  showErrorMessage: function(response) {
    console.log("something went wrong...")
  }
}