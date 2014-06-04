var WaypointGenerator = function(startPosition, endPosition){
  this.startPosition = startPosition
  this.endPosition = endPosition
  this.wayPoints = []
}

WaypointGenerator.prototype = {
  start: function() {
    this.midpoint = this.calcLatLongMidpoint();
    this.radius = this.calculateRadius();
    this.southPoint = this.calculateSouthPoint();
    this.eastPoint = this.calculateEastPoint();

    this.addVerticalWaypoints();
    this.addHorizontalWaypoints();
    // this.printFormattedWaypoints();
    return this.wayPoints
  },
  calcLatLongMidpoint: function() {
    var midpointK = (this.endPosition.k - this.startPosition.k) / 2 + this.startPosition.k
    var midpointA = (this.endPosition.A - this.startPosition.A) / 2 + this.startPosition.A
    return { k: midpointK, A: midpointA}
  },
  calculateRadius: function() {
    var squaredK = Math.pow((this.endPosition.k - this.startPosition.k), 2)
    var squaredA = Math.pow((this.endPosition.A - this.startPosition.A), 2)
    var hypot = Math.sqrt(squaredK + squaredA)
    return hypot/2
  },
  calculateSouthPoint: function() {
    if (this.midpoint.k > 0) {
      return { k: (this.midpoint.k - this.radius), A: this.midpoint.A }
    }
    else {
      return { k: (this.midpoint.k + this.radius), A: this.midpoint.A }
    }
  },
  calculateEastPoint: function() {
    if (this.midpoint.A > 0) {
      return { k: this.midpoint.k, A: (this.midpoint.A - this.radius) }
    }
    else {
      return { k: this.midpoint.k, A: (this.midpoint.A + this.radius) }
    }
  },
  addVerticalWaypoints: function() {
    var step = this.radius/3
    for (var i = 1; i < 6; i++) {
      this.wayPoints.push({ k: ( this.southPoint.k + step * i), A: this.southPoint.A })
    }
  },
  addHorizontalWaypoints: function() {
    var step = this.radius/3
    for (var i = 1; i < 6; i++) {
      this.wayPoints.push({ k: this.eastPoint.k, A: ( this.eastPoint.A - step * i) })
    }
  },
  printFormattedWaypoints: function() {
    for (var i = 0; i < this.wayPoints.length; i++) {
      console.log(this.wayPoints[i].k + ', ' + this.wayPoints[i].A)
    }
    console.log(this.startPosition.k + ', ' + this.startPosition.A)
    console.log(this.endPosition.k + ', ' + this.endPosition.A)
  }
}