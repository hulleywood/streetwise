var Slider = function(mapView) {
  this.step_size = 1
  this.mapView = mapView
  this.initialize()
}

Slider.prototype = {
  initialize: function() {
    this.setSlider()
    $("#safer").click(function(){ this.changeSliderValue(-1) }.bind(this))
    $("#shorter").click(function(){ this.changeSliderValue(1) }.bind(this))
    this.disable()
  },
  setSlider: function() {
    var newSlider = $("#slider").slider({
      min: 0,
      max: 3,
      value: 0,
      stop: function(e, ui) {
        this.updateMap()
      }.bind(this)
    });
  },
  changeSliderValue: function(times) {
    var value = $("#slider").slider( "option", "value" )
    var change = this.step_size * times
    if (change > 0 && value < 3) {
      $("#slider").slider( "option", "value", value + change )
      this.updateMap()
    }
    else if (change < 0 && value > 0) {
      $("#slider").slider( "option", "value", value + change )
      this.updateMap()
    }
  },
  enable: function() {
    $('.slider-row').show()
  },
  disable: function() {
    $('.slider-row').hide()
  },
  updateMap: function() {
    var value = $("#slider").slider( "option", "value" )
    this.mapView.showMapPath(value)
  }
}