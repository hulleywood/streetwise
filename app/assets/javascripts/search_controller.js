var SearchController = function() {
}

SearchController.prototype = {
  initiateDirectionSearch: function(e) {
    e.preventDefault();

    var startPoint = $(this).find('#start-point').val(),
        endPoint = $(this).find('#end-point').val();

    var mapView = new MapView();
        mapModel = new MapModel(startPoint, endPoint),
        directionsController = new DirectionsController(mapView, mapModel);

    directionsController.generateEndpointLatLong(directionsController, directionsController.generatePossibleDirections);
    // directionsController.generatePossibleDirections();
  }
}