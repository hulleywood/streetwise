var SearchController = function(mapView, slider) {
  this.mapView = mapView
  this.slider = slider
  this.initialize()
}

SearchController.prototype = {
  initialize: function() {
    this.mapView.initialize();
    this.bindAutocomplete();
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
    ajaxRequest.done(this.processResponse)
    ajaxRequest.fail(this.processErrors)
  },
  processResponse: function(response) {
    $('.directions-group').find('button').removeAttr('disabled');
    $('#errors').text('')
    this.slider.enable()
    this.mapView.resize()
    this.mapView.clearMapOverlays()
    this.mapView.addPathsToMap(response.paths)
    this.mapView.addMarkerToMap(response.origin, response.origin_coords)
    this.mapView.addMarkerToMap(response.destination, response.destination_coords)
    this.mapView.reboundMap([response.origin_coords, response.destination_coords])
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
    this.mapView.resize()
  },
  showErrorMessage: function(error) {
    $('#errors').append('<p>'+error+'</p>')
  }
}