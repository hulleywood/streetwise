$(document).ready(function() {
  var searchController = new SearchController();
  $('form#directions').submit(searchController.initiateDirectionSearch);
});