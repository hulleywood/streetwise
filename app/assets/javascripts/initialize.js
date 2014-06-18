$(document).ready(function() {
  var mapView = new MapView()
  searchController = new SearchController(mapView);
  mapView.resize();
  $('button.directions').on('click', searchController.initiateDirectionSearch.bind(searchController));
});
