var Slider = function() {
  this.step_size = 1
  this.initialize()
}

Slider.prototype = {
  initialize: function() {
    this.setSlider()
    $("#safer").click(function(){ this.changeSliderValue(-1) }.bind(this))
    $("#shorter").click(function(){ this.changeSliderValue(1) }.bind(this))
  },
  setSlider: function() {
    var newSlider = $("#slider").slider({
      min: 1,
      max: 4,
      value: 1,
      stop: function(e, ui) {
        this.updateMap()
      }.bind(this)
    });
  },
  changeSliderValue: function(times) {
    var value = $("#slider").slider( "option", "value" )
    var change = this.step_size * times
    if (change > 0 && value < 4) {
      $("#slider").slider( "option", "value", value + change )
      this.updateMap()
    }
    else if (change < 0 && value > 1) {
      $("#slider").slider( "option", "value", value + change )
      this.updateMap()
    }
  },
  enable: function() {
    $('.slider-row').show()
  },
  updateMap: function() {
    var value = $("#slider").slider( "option", "value" )
    console.log(value)
  }
}