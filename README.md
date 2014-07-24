##StreetWise

StreetWise provides walking directions that take your environment into account. StreetWise uses SFGov Crime Data and OpenStreetMap Data to provide possible routes from point A to point B ranging from shortest to safest.

StreetWise is currently limited to the SF Metro Area.

StreetWise is live: [http://streetwise.herokuapp.com](http://streetwise.herokuapp.com)

Coming soon, [StreetWise iOS!](https://github.com/jhulley/StreetWiseiOS)


##How It Works

Streetwise utlizes Neo4j (a graph database) because of it's built-in path traversal capabilities. The graph is a series of nodes connected by relationships that have weight properties (i.e. safest, shortest, etc). The weight of a relationship is the normalized crime rating, or the number of crimes recently committed near a node, multiplied by a coefficient, determined by the median crime rating and distance, and added to the distance between it's endpoints.

The current version of StreetWise selects the nearest nodes to the address of the origin and destination then traverses the graph for each weighting using the nodes as endpoints. In an effort to increase the speed of traversal, intersection relationships are currently being added to the database and the traversal will use that relationship. There are approx 67,000 normal nodes in the database and only 16,000 of them are intersections.


##Installation

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
rake seed:latest_crimes                           #requires API key for SFGov Data

rake osm_data_creation:create_waypoints           #requires OSM data file
rake osm_data_creation:create_sf_nodes            #requires OSM data file

rake osm_data_clean:remove_non_waypoint_nodes
rake osm_data_clean:remove_waypoints_outside_sf
rake osm_data_clean:find_intersection_nodes
rake osm_data_clean:calculate_node_crime_rating

rake graph_seed:create_graph_nodes                #6700 seconds
rake graph_seed:create_neighbor_relationships     #13300 seconds
rake graph_seed:create_node_labels                #2037 seconds
rake graph_seed:create_intersects_relationships   # seconds
```


##Current WIP
* Test Suite
* Back-end rewrite to search intersection-intersection instead of node-node
* Client-side updates (i.e. slider default position, request data structure)
* GraphDB traversal speed
* Overall performance optimization
* Some iOS support modifications to the response data structure


##Future Improvements
* Reduce coupling between models
* Revise methods used in Rake tasks
* Polyline encoding server-side
* Rewrite closest node methods to use neo instead of PG
* Provide actual directions instead of just view of polyline with endpoints
* Some resultant paths link roads that cannot be traversed, need to determine cause
* Examine crimes, potentially filter or weight (i.e. murder/mugging worse than jaywalking)
* Allow intersection searching, not just places
* Recenter map on User's location if in SF
* Add "my location" to autcomplete search