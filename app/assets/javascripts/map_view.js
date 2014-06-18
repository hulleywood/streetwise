var MapView = function() {

}

MapView.prototype = {
  resize: function(){
    var navHeight = $(".navbar").height()
    + parseInt($(".navbar").css("margin-bottom"))
    + parseInt($(".navbar").css("margin-top"))

    var searchHeight = $(".directions-group").height()
    + parseInt($(".directions-group").css("margin-bottom"))
    + parseInt($(".directions-group").css("margin-top"))

    var errorHeight = $("#errors").height()
    + parseInt($("#errors").css("margin-bottom"))
    + parseInt($("#errors").css("margin-top"))

    var mapMargin = parseInt($('#map-canvas').css("margin-bottom"))
    var windowHeight = $(window).height()

    var height = windowHeight - navHeight - searchHeight - errorHeight - mapMargin - 5

    $('#map-canvas').height( height );
  }
}