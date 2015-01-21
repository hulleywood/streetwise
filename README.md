##StreetWise

StreetWise provides walking directions that take your environment into account. StreetWise uses SFGov Crime Data and OpenStreetMap Data to provide possible routes from point A to point B ranging from shortest to safest.

StreetWise is currently limited to the SF Metro Area.

StreetWise is live: [http://streetwise.herokuapp.com](http://streetwise.herokuapp.com)

Coming soon, [StreetWise iOS!](https://github.com/jhulley/StreetWiseiOS)


##How It Works

Streetwise utlizes Neo4j (a graph database) because of it's built-in path traversal capabilities. The graph is a series of nodes connected by relationships that have weight properties (i.e. safest, shortest, etc). The weight of a relationship is the normalized crime rating, or the number of crimes recently committed near a node, multiplied by a coefficient, determined by the median crime rating and distance, and added to the distance between it's endpoints.

Streetwise uses the coordinates of the origin and destination from the request object to find the closest intersection node (done with a combo of Manhattan Distances and Haversine) then traverses the graph for each weighting using the nodes as endpoints. Geocoding is done client-side because the coordinates are already in the Google Places response object due to the use of AutoComplete.


##Installation

__Updates Coming Soon__

[Setup Neo4j](http://www.neo4j.org/download)

Clone the repo:

```
git clone https://github.com/jhulley/streetwise.git
```

CD into the directory:

```
cd streetwise
```

Run bundle:

```
bundle
```

Create & setup the database:

```
rake db:create
rake db:migrate
```

Seed the database (note: these tasks take a very long time to run, like hours and hours):

```
rake seed:latest_crimes                           #700    seconds, requires API key for SFGov Data

rake osm_data_creation:create_sf_nodes            #1200   seconds, requires OSM data file
rake osm_data_creation:create_waypoints           #5000   seconds, requires OSM data file

rake osm_data_clean:remove_non_waypoint_nodes     #11900  seconds
rake osm_data_clean:remove_waypoints_outside_sf   #2820   seconds
rake osm_data_clean:find_intersection_nodes       #800    seconds
rake osm_data_clean:calculate_node_crime_rating   #8300   seconds

rake graph_seed:create_graph_nodes                #6700   seconds
rake graph_seed:create_neighbor_relationships     #13300  seconds
rake graph_seed:create_node_labels                #2100   seconds
rake graph_seed:create_intersects_relationships   #6400   seconds
```


##Current WIP
* Test Suite


##Future Improvements
* Reduce coupling between models
* Polyline encoding server-side
* Provide actual directions instead of just view of polyline with endpoints
* Examine crimes, potentially filter or weight (i.e. murder/mugging worse than jaywalking)
* Allow intersection searching, not just places
* Recenter map on User's location if in SF
* Add "my location" to autcomplete search
