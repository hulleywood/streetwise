$(document).ready(function() {
  searchController = new SearchController();
  $('form#directions').submit(searchController.initiateDirectionSearch.bind(searchController));
  $(window).resize();
});

$(window).resize(function(){
  var navHeight = $(".navbar").height()
    + parseInt($(".navbar").css("margin-bottom"))
    + parseInt($(".navbar").css("margin-top"))

  var searchHeight = $("#directions").height()
    + parseInt($("#directions").css("margin-bottom"))
    + parseInt($("#directions").css("margin-top"))

  var mapMargin = parseInt($('#map-canvas').css("margin-bottom"))
  var windowHeight = $(window).height()
  var height = windowHeight - navHeight - searchHeight
    - mapMargin - 5

  $('#map-canvas').height( height );
})
