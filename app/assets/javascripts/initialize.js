$(document).ready(function() {
  searchController = new SearchController();
  $('form#directions').submit(searchController.initiateDirectionSearch.bind(searchController));
});