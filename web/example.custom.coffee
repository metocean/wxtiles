# # Custom Example
# Loading wxtiles manually.

# There are several different wxservers, here we are selecting the open one.
serverurl = 'http://api.thomas.dev/public/apikey/open/'
domain = 'metoceanview.com'

# We use wxtiles to load a configuration from the wxserver.
wxtiles.loadConfiguration serverurl, domain, (config) ->
	# All the keys are in config.keys. A key is an index into a list of tiles. For the base weather tiles all keys are times in the future. For other tile sets other keys are available.
	console.log 'KEYS'
	for key in config.keys
		console.log "#{key.name}: #{key.description}"
	
	# All the fields are in config.fields. A field is a tracked variable such as sea surface temperature, wind 10m above sea, or precipitation.
	console.log 'FIELDS'
	for field in config.fields
		console.log "#{field.name}: #{field.description}"
	
	# For this example we are displaying a randomly selected field and starting with a key from the middle. Generally you would want to select the field that was relevant to your application and probably change the key based on a timeline or dropdown.
	randomindex = Math.floor Math.random() * config.fields.length
	field = config.fields[randomindex]
	key = config.keys[Math.round(config.keys.length / 2)]
	
	console.log "DISPLAYING #{field.description} @ #{key.description}"

	# Like any leafletjs tile layer we create a specially crafted URL with the z, x, and y variables that leaflet uses to request tiles at specific coordinates and zoom levels. Our Y axis is inverted so use `tms: yes` to tell leaflet. Our high quality tiles are available to zoom level 14 and our open tiles are available to zoom level 7.
	exampleLayer = L.tileLayer "#{serverurl}tile/#{config.cycle}/#{field.name}/#{key.name}/{z}/{x}/{y}.png",
		opacity: field.defaultalpha
		maxZoom: 7
		maxNativeZoom: 8
		tms: yes
		reuseTiles: yes
		#detectRetina: yes
	
	# We're using an example ocean tile layer from nzapstrike, this could be OpenStreetMap, MapBox or any other base tile provider.
	nzapstrike = L.tileLayer 'http://map{s}.nzapstrike.net/aqua3/{z}/{x}/{y}.png',
		maxZoom: 8
		reuseTiles: yes
		#detectRetina: yes
	
	# Once we've selected a field, key and created two tile layers we put them together and create a leaflet map centred over New Zealand.
	map = new L.Map 'map',
		layers: [nzapstrike, exampleLayer]
		center: new L.LatLng -37.7772, 175.2756
		zoom: 6
		attributionControl: no
	
	# This example is very much a roll your own example.