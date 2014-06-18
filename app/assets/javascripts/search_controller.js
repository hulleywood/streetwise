var SearchController = function(mapView) {
  this.mapView = mapView
  this.map
  this.directionsDisplay = new google.maps.DirectionsRenderer();
  this.directionsService = new google.maps.DirectionsService();
  this.geocoder = new google.maps.Geocoder();
  this.bounds = new google.maps.LatLngBounds();
  this.initialize()
  this.overlays = []
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
    var inputs = $('.directions-group input')
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
    var form = $('.directions-group')
    var response = this.processForm(form)
    if (response.status === 200) {
      $(form).find('button').attr('disabled', 'disabled');
      this.sendDirectionRequest(response.data)
    }
    else {
      this.displayErrorMessages(response.data)
    }
  },
  processForm: function(form) {
    var status = this.validForm(form)
    var data
    if (status === 200) {
      data = this.getFormData(form)
    }
    else {
      data = ["You must enter an origin and a destination"]
    }
    return { status: status, data: data }
  },
  validForm: function(form) {
    var origin
    if (form.find('#origin').val() != "" && form.find('#destination').val() != "") {
      return 200
    }
    else {
      return 422
    }
  },
  getFormData: function(form) {
    var origin = form.find('#origin').val()
    var destination = form.find('#destination').val()
    return { origin: origin, destination: destination }
  },
  sendDirectionRequest: function(data) {
    var ajaxRequest = $.ajax({
      context: this,
      url: "directions/:id",
      type: 'GET',
      data: data
    })
    ajaxRequest.done(this.processDirections)
    ajaxRequest.fail(this.processErrors)
  },
  processDirections: function(response) {
    $('.directions-group').find('button').removeAttr('disabled');
    this.clearMapOverlays()
    this.addPathToMap(response.path)
    this.addMarkerToMap(response.origin, response.origin_coords)
    this.addMarkerToMap(response.destination, response.destination_coords)
    this.reboundMap([response.origin_coords, response.destination_coords])
  },
  processErrors: function(response) {
    $('.directions-group').find('button').removeAttr('disabled');
    this.displayErrorMessages([response.statusText])
  },
  displayErrorMessages: function(errors) {
    $('#errors').text('')
    for (var i = 0; i < errors.length; i++) {
      this.showErrorMessage(errors[i])
    }
    this.mapView.resize();
  },
  showErrorMessage: function(error) {
    $('#errors').append('<p>'+error+'</p>')
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
  addMarkerToMap: function(address, coords) {
    var latLon = new google.maps.LatLng(coords.lat, coords.lon);
    var marker = new google.maps.Marker({
        position: latLon,
        map: this.map,
        title: address
    });
    this.overlays.push(marker)
  },
  reboundMap: function(coords) {
    for (var i = 0; i < coords.length; i++) {
          var latLon = new google.maps.LatLng(coords[i].lat, coords[i].lon)
          this.bounds.extend(latLon)
    }
    this.map.fitBounds(this.bounds)
  },
  clearMapOverlays: function() {
    for (var i = 0; i < this.overlays.length; i ++) {
      this.overlays[i].setMap(null)
    }
  }
}