var SearchController = function(mapView, slider) {
  this.mapView = mapView;
  this.slider = slider;
  this.initialize();
  this.originCoords;
  this.destinationCoords;
  this.sfMinLat = 37.696132;
  this.sfMaxLat = 37.810234;
  this.sfMinLon = -122.519413;
  this.sfMaxLon = -122.347423;
}

SearchController.prototype = {
  initialize: function() {
    this.mapView.initialize()
    this.bindAutocomplete()
    this.hideErrors()
    $('#search-btn').click(this.toggleSearch.bind(this))
    $('#about-btn').click(this.toggleAbout.bind(this))
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

    this.autocomplete_start = new google.maps.places.Autocomplete(inputs[0], options);
    this.autocomplete_end = new google.maps.places.Autocomplete(inputs[1], options);

    google.maps.event.addListener(this.autocomplete_start, 'place_changed', function() {
      this.originCoords = this.autocomplete_start.getPlace().geometry.location;
    }.bind(this));
    google.maps.event.addListener(this.autocomplete_end, 'place_changed', function() {
      this.destinationCoords = this.autocomplete_end.getPlace().geometry.location;
    }.bind(this));
  },

  initiateDirectionSearch: function(e) {
    e.preventDefault();
    var form = $('.directions-group')
    var response = this.processForm(form)
    if (response.status === 200) {
      $(form).find('button').attr('disabled', 'disabled');
      this.hideErrors();
      this.slider.disable();
      this.mapView.resize();
      $('body').addClass('loading');
      this.sendDirectionRequest(response.data);
    }
    else {
      this.displayErrorMessages(response.data);
    }
  },

  processForm: function(form) {
    var status = this.validateForm(form)
    var data
    if (status === 200) {
      data = this.getRequestData();
    }
    else if (status === 422) {
      data = ["You must enter an origin and a destination"]
    }
    else if (status === 400){
      data = ["Please select your endpoints from the search menu"]
    }
    else {
      data = ["Your endpoints must be within San Francisco"]
    }
    return { status: status, data: data }
  },

  validateForm: function(form) {
    if (form.find('#origin').val() == "" || form.find('#destination').val() != "") {
      return 422
    }
    if (!this.originCoords && !this.destinationCoords) {
      return 400
    }
    if (this.originCoords.k > this.sfMaxLat || this.originCoords.k < this.sfMinLat) {
      return 406
    }
    if (this.originCoords.B > this.sfMaxLon || this.originCoords.B < this.sfMinLon) {
      return 406
    }
    if (this.destinationCoords.k > this.sfMaxLat || this.destinationCoords.k < this.sfMinLat) {
      return 406
    }
    if (this.destinationCoords.B > this.sfMaxLon || this.destinationCoords.B < this.sfMinLon) {
      return 406
    }
  },

  getRequestData: function() {
    var origin = { lat: this.originCoords.k, lon: this.originCoords.B }
    var destination = { lat: this.destinationCoords.k, lon: this.destinationCoords.B }
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
    $('body').removeClass('loading')
    $('.directions-group').find('button').removeAttr('disabled');
    $('#errors').text('')
    this.slider.enable()
    this.slider.sliderInitialPosition()
    this.toggleSearch()
    this.mapView.resize()
    this.mapView.removeOldOverlays()
    this.mapView.addPathsToMap(response.paths)
    this.mapView.addMarkerToMap(response.origin, response.origin_coords)
    this.mapView.addMarkerToMap(response.destination, response.destination_coords)
    this.mapView.reboundMap([response.origin_coords, response.destination_coords])
  },

  processErrors: function(response) {
    $('body').removeClass('loading')
    $('.directions-group').find('button').removeAttr('disabled');
    this.displayErrorMessages([response.statusText])
  },

  displayErrorMessages: function(errors) {
    $('#errors').text('')
    for (var i = 0; i < errors.length; i++) {
      this.showErrorMessage(errors[i])
    }
    this.showErrors()
  },

  showErrorMessage: function(error) {
    $('#errors').append('<p>'+error+'</p>')
  },

  showErrors: function(){
    $('#errors').show()
    this.mapView.resize()
  },

  hideErrors: function(){
    $('#errors').hide()
    this.mapView.resize()
  },

  toggleSearch: function() {
    $('.directions-group').toggle()
    this.mapView.resize()
  },

  toggleAbout: function() {
    setTimeout( this.mapView.resize, 350)
  }
}