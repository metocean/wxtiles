# # Leaflet Example
# Here is some example code of how to use wxtiles on a leaflet map

serverurl = 'http://localhost:8008/apikey/open/'
domain = 'metoceanview.com'

wxtiles.loadConfiguration serverurl, domain, (config) ->
	# all the keys are in config.keys
	console.log 'KEYS'
	for key in config.keys
		console.log "#{key.name}: #{key.description}"
	
	# all the fields are in config.fields
	console.log 'FIELDS'
	for field in config.fields
		console.log "#{field.name}: #{field.description}"
	
	# display a random field and the middle key
	randomindex = Math.floor Math.random() * config.fields.length
	field = config.fields[randomindex]
	key = config.keys[Math.round(config.keys.length / 2)]
	
	console.log "DISPLAYING #{field.description}"
	console.log "@ #{key.description}"

	exampleLayer = L.tileLayer "#{serverurl}tile/#{config.cycle}/#{field.name}/#{key.name}/{z}/{x}/{y}.png",
		opacity: field.defaultalpha
		maxZoom: 14
		tms: yes
	
	# We're using an ocean tile layer from nzapstrike
	nzapstrike = L.tileLayer 'http://map{s}.nzapstrike.net/aqua3/{z}/{x}/{y}.png',
		maxZoom: 8
	
	# Create a leaflet map and centre it over New Zealand
	map = new L.Map 'map',
		layers: [nzapstrike, exampleLayer]
		center: new L.LatLng -37.7772, 175.2756
		zoom: 7