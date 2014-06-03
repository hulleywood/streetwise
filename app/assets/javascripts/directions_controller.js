var DirectionsController = function(view, model){
  this.view = view
  this.model = model
}

DirectionsController.prototype = {
  generateDirections: function() {
    console.log(this.model.startPoint)
    console.log(this.model.endPoint)
  }
}