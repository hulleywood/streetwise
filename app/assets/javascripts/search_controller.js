var SearchController = function() {
}

SearchController.prototype = {
  initiateDirectionSearch: function(e) {
    e.preventDefault();

    var ajaxRequest = $.ajax({
      url: this.action,
      type: this.method,
      data: $(this).serialize()
    })

    // ajaxRequest.done(this.showDirections)
    // ajaxRequest.fail(this.showErrorMessage)
    ajaxRequest.done(showDirections)
    ajaxRequest.fail(showErrorMessage)

    // var startPoint = $(this).find('#start-point').val(),
        // endPoint = $(this).find('#end-point').val();

    // var mapView = new MapView();
        // mapModel = new MapModel(startPoint, endPoint),
        // directionsController = new DirectionsController(mapView, mapModel);

    // directionsController.generateEndpointLatLong(directionsController, directionsController.generatePossibleDirections);
    // directionsController.generatePossibleDirections();
  },
  showDirections: function() {
    console.log("showDirections in controller")
    debugger
  },
  showErrorMessage: function() {
    console.log("showError in controller")
    debugger
  }
}

function showDirections(data) {
  console.log(data)
  console.log("showDirections in controller")
}

function showErrorMessage(data) {
  console.log(data)
  console.log("showError in controller")
}