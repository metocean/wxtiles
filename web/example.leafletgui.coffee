# # Leaflet Example
# Using wxtiles as a leaflet tilelayer.

# There are several different wxservers, here we are selecting the open one.
serverurl = 'http://localhost:8008/apikey/open/'
domain = 'metoceanview.com'

# We use wxtiles to load a configuration from the wxserver.
wxtiles.loadConfiguration serverurl, domain, (config) ->
	map = new L.Map 'map',
		center: new L.LatLng -37.7772, 175.2756
		zoom: 6
		attributionControl: no
	
	# We're creating a layer for each field.
	overlays = {}
	for field in config.fields
		layer = L.wxTileLayer config,
			maxZoom: 7
			maxNativeZoom: 8
			reuseTiles: yes
			#detectRetina: yes
		
		layer.setField field
		overlays[field.description] = layer

	baselayer = L.tileLayer 'http://map{s}.nzapstrike.net/aqua3/{z}/{x}/{y}.png',
		maxZoom: 8
		reuseTiles: yes
		#detectRetina: yes

	# The minimap is used to turn layers on and off.
	# It has been customised slightly to deal with the wxTileLayer
	layersControl = L.control.layers
		.minimap 'Base Layer': baselayer, overlays,
			collapsed: no
			overlayBackgroundLayer: baselayer
		.addTo map
	
	baselayer.addTo map