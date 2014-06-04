##StreetWise

StreetWise is an app that provides walking directions that take your environment into account. StreetWise generates a number of possible routes from point A to point B and uses SFGov crime data from the last 3 months to rank and select the "safest" one.

StreetWise is currently limited to the SF Metro Area. iOS and Android apps coming soon.

StreetWise is live: [http://streetwise.herokuapp.com](http://streetwise.herokuapp.com)

###ToDos

* Disable submit button until Ajax return
* Autocomplete routes
* Geocode and validate user inputs client side
* Server should return directions, not just start/end/midpoints (requires additional API request)
* Investigate async processing of directional "safety" (threading?)
* Limit columns in database to useful info
* Use max-crimes in route selection process
* Write about section for website
* Style website for desktop and mobile
* Allow multiple direction requests without refreshing page
