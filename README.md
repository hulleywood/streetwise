##StreetWise

StreetWise provides walking directions that take your environment into account. StreetWise uses SFGov Crime Data and OpenStreetMap Data to provide possible routes from point A to point B ranging from shortest to safest.

Streetwise utlizes a graph database because of the advantages it provides over an object-relational database like postgres. The graph is a series of nodes connected by relationships that have weight properties. The weight of a relationship is the normalized crime rating, or the number of crimes recently committed near a node, multiplied by a coefficient and added to distance.

StreetWise is currently limited to the SF Metro Area.

StreetWise is live: [http://streetwise.herokuapp.com](http://streetwise.herokuapp.com)


###How It Works
Coming soon...


###Further Improvements
* There are still a number of Google API calls being made due mainly to the encoding of the polyline, this should be able to be decreased with custom polyline creation or map display.
* Give actual directions instead of just view of polyline with enpooints
* Some resultant paths link roads that cannot be traversed, need to determine cause
* Take time of day into account, filter crimes by travel time

###Bugs
* Allow intersection searching, not just places
