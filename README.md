##StreetWise

StreetWise provides walking directions that take your environment into account. StreetWise uses SFGov Crime Data and OpenStreetMap Data to provide the best route possible from point A to point B. Streetwise utlizes a graph database because of the huge advantages it provides over a typical database like postgres. The graph is a series of nodes connected by relationships that have weight properties. The weight of a relationship is the normalized average of crime_rating and distance.

StreetWise is currently limited to the SF Metro Area.

StreetWise v2 is live: [http://streetwise.herokuapp.com](http://streetwise.herokuapp.com)


###How It Works



###Further Improvements
* The longest part of the process is finding the closest node to the origin and destination; surely this can be optimized or threaded.
* There are still a number of Google API calls being made due mainly to the encoding of the polyline, this should be able to be decreased with custom polyline creation or map display.
* Directions aren't actually given, just view of polyline.
