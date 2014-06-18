##StreetWise

StreetWise is an app that provides walking directions that take your environment into account. StreetWise generates a number of possible routes from point A to point B and uses SFGov crime data from the last 3 months to rank and select the "safest" one.

StreetWise is currently limited to the SF Metro Area.

StreetWise v1 is live: [http://streetwise.herokuapp.com](http://streetwise.herokuapp.com)


###v1
v1 of StreetWise uses the "recommended" route from GoogleMaps and generates waypoints surrounding each node of the recommended route. After generating a set of possible routes using each one of the waypoints (each one corresponds to one possible route), StreetWise analyzes each route based on the average number of crimes within a block of each point along the route. By using the average number of crimes, routes having different numbers of nodes are weighted equally and the "average safety" is the deciding factor. Finally the route with the lowest average crime number is choosen and sent to the client to be rendered.

This approach yields a result, but leaves much to be desired. The maximum number of crimes within a block of each node on a route is calculated but not used at this point. The ideally, both average crime numbers and max crime number would be weighted and used in route selection. This approach also makes many Google API calls and while that works for a single user in development, it is not particulary quick or viable for more than a few users per day.

v1 ToDos:
* Investigate async processing of directional "safety" (threading?)
* Limit columns in database to useful info
* Use max-crimes in route selection process


###v2
v2 of StreetWise is currently in progress and will entail a significantly higher amount of computation and data than v1. The goal for v2 is to use OpenStreetMap data for San Francisco to generate a nodal graph of the intersections in the city, assign a safety rating to each one, and use traversal algorithms to choose the best route based on multiple factors (safety, distance, type of road, etc). With this approach, extending the feature set to include things like finding the best route from A to B with the least intense gradient at any one point much easier to implement.


Neo4j Implementation

After doing some further research on graphs and node traversal, it seems like a good idea to try using a graph database to store the data and use for traversal. After playing with the potential schema for a bit, what I've decided to pursue is:

* Every walkable node from the PG database gets migrated to the graph DB
* Each node in the graph has: lat, lon, crime_rating, intersection
* Each node is connected to it's neighbors through a "walkable" relationship that has 3 properties
 * Distance
 * Crime
 * Total cost (some combination of distance and crime)
* Each node that is an intersection is connected to it's intersectional neighbors with a relationshp (same props)
* To find the shortest path, the instersectional relationships are traversed using weights based off total cost
* Rake tasks are written that will update the crime ratings for each node
* After the crimes are updated, each intersectional relationship must be updated with the new crime numbers


###ToDos

* Autocomplete routes
* Geocode and validate user inputs client side
* Server should return directions, not just start/end/midpoints (requires additional API request)
* Write about section for website
* Style website for desktop and mobile


###Bugs

* When creating waypoints, the next_node_id and previous_node_id fields are always nil, yet waypoint.next_nod returns the correct Node object
* Neo4j database indices do not start at 0
