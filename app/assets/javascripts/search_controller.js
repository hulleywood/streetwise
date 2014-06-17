var SearchController = function() {
  this.map
  this.directionsDisplay = new google.maps.DirectionsRenderer();
  this.directionsService = new google.maps.DirectionsService();
  this.initialize()
  // google.maps.event.addDomListener(window, 'load', initialize);
}

SearchController.prototype = {
  initialize: function() {
    this.showInitialMap();
    this.bindAutocomplete();
  },
  showInitialMap: function() {
    var sanFran = new google.maps.LatLng(37.7833, -122.4167);
    var mapOptions = {
      zoom:12,
      center: sanFran
    }
    this.map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
    this.directionsDisplay.setMap(this.map);
  },
  bindAutocomplete: function() {
    var inputs = $('#directions input')
    console.log(inputs[0])
    console.log(inputs[1])
    var bounds = new google.maps.LatLngBounds(
      new google.maps.LatLng(37.7833, -122.4167)
    );
    var options = {
      bounds: bounds,
      componentRestrictions: {country: 'us'}
    };
    var autocomplete_start = new google.maps.places.Autocomplete(inputs[0], options);
    var autocomplete_end = new google.maps.places.Autocomplete(inputs[1], options);
  },
  initiateDirectionSearch: function(e) {
    e.preventDefault();
    var form = $('form#directions')[0]
    $(form).find('button').attr('disabled', 'disabled');
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
    $('form#directions').find('button').removeAttr('disabled');

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
    $('form#directions').find('button').removeAttr('disabled');

    console.log("something went wrong...")
  }
}