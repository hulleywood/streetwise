$(document).ready(function() {
  var mapView = new MapView()
  var slider = new Slider()
  searchController = new SearchController(mapView, slider);
  mapView.resize();
  $('button.directions').on('click', searchController.initiateDirectionSearch.bind(searchController));
});