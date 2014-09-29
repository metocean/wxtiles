# # Leaflet Example
# Using wxtiles as a leaflet tilelayer.

# There are several different wxservers, here we are selecting the open one.
serverurl = 'http://localhost:8008/apikey/open/'
domain = 'metoceanview.com'

# We use wxtiles to load a configuration from the wxserver.
wxtiles.loadConfiguration serverurl, domain, (config) ->

	# We create the wxTileLayer. Our high quality tiles are available to zoom level 14 and our open tiles are available to zoom level 7.
	wxTilesLayer = L.wxTileLayer config,
		maxZoom: 7
		maxNativeZoom: 8
		reuseTiles: yes
		#detectRetina: yes
	
	# For this example we are displaying a randomly selected field. Generally you would want to select the field that was relevant to your application.
	randomindex = Math.floor Math.random() * config.fields.length
	wxTilesLayer.setField config.fields[randomindex]
	
	# We're using an example ocean tile layer from nzapstrike, this could be OpenStreetMap, MapBox or any other base tile provider.
	nzapstrike = L.tileLayer 'http://map{s}.nzapstrike.net/aqua3/{z}/{x}/{y}.png',
		maxZoom: 8
		reuseTiles: yes
		#detectRetina: yes
	
	# Once we've created two tile layers we put them together and create a leaflet map centred over New Zealand.
	map = new L.Map 'map',
		layers: [nzapstrike, wxTilesLayer]
		center: new L.LatLng -37.7772, 175.2756
		zoom: 6
		attributionControl: no
	
	# We can dynamically update the key by calling back, forward or setting a key directly.
	setTimeout ->
		wxTilesLayer.forward()
	, 10000