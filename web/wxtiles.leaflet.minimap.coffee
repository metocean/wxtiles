# # WXTilesMinimap
#
# Layers control with synced minimaps for WXTiles.
# Based largely on minimap by Jan Pieter Waagmeester <jieter@jieter.nl>

_cloneLayer = (layer) ->
	options = layer.options
	if layer instanceof L.WXTileLayer
		result = L.wxTileLayer layer._config, options
		result.setField layer._field
		result.setKey layer._key
		return result
	return L.tileLayer(layer._url, options) if layer instanceof L.TileLayer
	return L.imageOverlay(layer._url, layer._bounds, options) if layer instanceof L.ImageOverlay
	return L.polygon(layer.getLatLngs(), options) if layer instanceof L.Polygon or layer instanceof L.Rectangle
	return L.marker(layer.getLatLng(), options) if layer instanceof L.Marker
	return L.circleMarker(layer.getLatLng(), options) if layer instanceof L.circleMarker
	return L.polyline(layer.getLatLngs(), options) if layer instanceof L.Polyline
	return L.polyline(layer.getLatLngs(), options) if layer instanceof L.MultiPolyline
	return L.MultiPolygon(layer.getLatLngs(), options) if layer instanceof L.MultiPolygon
	return L.circle(layer.getLatLng(), layer.getRadius(), options) if layer instanceof L.Circle
	return L.geoJson(layer.toGeoJSON(), options) if layer instanceof L.GeoJSON
	
	# no interaction on minimaps, add FeatureGroup as LayerGroup
	if layer instanceof L.LayerGroup or layer instanceof L.FeatureGroup
		layergroup = L.layerGroup()
		layer.eachLayer (inner) ->
			layergroup.addLayer _cloneLayer inner
		layergroup

L.Control.Layers.WXTilesMinimap = L.Control.extend
	options:
		collapsed: yes
		autoZIndex: yes
		position: 'topright'
		topPadding: 10
		bottomPadding: 40
		backgroundLayer: L.tileLayer 'http://a{s}.acetate.geoiq.com/tiles/acetate-base/{z}/{x}/{y}.png',
			attribution: '&copy;2012 Esri & Stamen, Data from OSM and Natural Earth'
			subdomains: '0123'
			minZoom: 2
			maxZoom: 18

	initialize: (layers, options) ->
		L.setOptions @, options
		@_layers = {}
		@_lastZIndex = 0
		@_handlingClick = no
		for i of layers
			@_addLayer layers[i], i

	onAdd: (map) ->
		@_initLayout()
		@_update()
		map.on('layeradd', @_onLayerChange, @).on 'layerremove', @_onLayerChange, @
		@_container

	onRemove: (map) ->
		map.off('layeradd', @_onLayerChange, @).off 'layerremove', @_onLayerChange, @

	addLayer: (layer, name) ->
		@_addLayer layer, name
		@_update()
		@

	removeLayer: (layer) ->
		id = L.stamp layer
		delete @_layers[id]
		@_update()
		@

	_addLayer: (layer, name) ->
		id = L.stamp layer
		@_layers[id] =
			layer: layer
			name: name

		if @options.autoZIndex and layer.setZIndex
			@_lastZIndex++
			layer.setZIndex @_lastZIndex

	_onLayerChange: (e) ->
		obj = @_layers[L.stamp(e.layer)]
		return unless obj
		@_update()  unless @_handlingClick
		type = (if e.type is 'layeradd' then 'overlayadd' else 'overlayremove')
		@_map.fire type, obj  if type

	filter: (string) ->
		string = string.trim()
		layerLabels = @_container.querySelectorAll 'label'
		i = 0

		while i < layerLabels.length
			layerLabel = layerLabels[i]
			if string isnt '' and layerLabel._layerName.indexOf(string) is -1
				L.DomUtil.addClass layerLabel, 'leaflet-minimap-hidden'
			else
				L.DomUtil.removeClass layerLabel, 'leaflet-minimap-hidden'
			i++
		@_onListScroll()

	isCollapsed: ->
		not L.DomUtil.hasClass @_container, 'leaflet-control-layers-expanded'

	_expand: ->
		L.DomUtil.addClass @_container, 'leaflet-control-layers-expanded'
		@_onListScroll()

	_collapse: ->
		@_container.className = @_container.className.replace ' leaflet-control-layers-expanded', ''

	_initLayout: ->
		className = 'leaflet-control-layers'
		container = @_container = L.DomUtil.create 'div', className
		
		#Makes this work on IE10 Touch devices by stopping it from firing a mouseout event when the touch is released
		container.setAttribute 'aria-haspopup', yes
		unless L.Browser.touch
			L.DomEvent.disableClickPropagation(container).disableScrollPropagation container
		else
			L.DomEvent.on container, 'click', L.DomEvent.stopPropagation
		form = @_form = L.DomUtil.create('form', className + '-list')
		if @options.collapsed
			L.DomEvent.on(container, 'mouseover', @_expand, @).on container, 'mouseout', @_collapse, @  unless L.Browser.android
			link = @_layersLink = L.DomUtil.create('a', className + '-toggle', container)
			link.href = '#'
			link.title = 'Layers'
			if L.Browser.touch
				L.DomEvent.on(link, 'click', L.DomEvent.stop).on link, 'click', @_expand, @
			else
				L.DomEvent.on link, 'focus', @_expand, @
			
			#Work around for Firefox android issue https://github.com/Leaflet/Leaflet/issues/2033
			L.DomEvent.on form, 'click', (->
				setTimeout L.bind(@_onInputClick, @), 0
				return
			), @
			@_map.on 'click', @_collapse, @
		
		# TODO keyboard accessibility
		else
			@_expand()
			
		@_layerList = L.DomUtil.create('div', className + '-layers', form)
		container.appendChild form
		L.DomUtil.addClass @_container, 'leaflet-control-layers-minimap'
		L.DomEvent.on @_container, 'scroll', @_onListScroll, @

	_update: ->
		if @_container
			@_layerList.innerHTML = ""
			@_addItem layer for _, layer of @_layers
		
		@_map.on 'resize', @_onResize, @
		@_onResize()
		@_map.whenReady @_onListScroll, @

	# IE7 bugs out if you create a radio dynamically, so you have to do it this hacky way (see http://bit.ly/PqYLBe)
	_createRadioElement: (name, checked) ->
		radioHtml = "<input type=\"radio\" class=\"leaflet-control-layers-selector\" name=\"" + name + "\""
		radioHtml += " checked=\"checked\"" if checked
		radioHtml += "/>"
		radioFragment = document.createElement 'div'
		radioFragment.innerHTML = radioHtml
		radioFragment.firstChild

	_addItem: (obj) ->
		container = @_layerList
		label = L.DomUtil.create 'label', 'leaflet-minimap-container', container
		label._layerName = obj.name
		checked = @_map.hasLayer obj.layer
		@_createMinimap L.DomUtil.create('div', 'leaflet-minimap', label), obj.layer
		span = L.DomUtil.create 'span', 'leaflet-minimap-label', label
		input = @_createRadioElement 'leaflet-control-layers-selector', checked
		input.layerId = L.stamp obj.layer
		span.appendChild input
		L.DomEvent.on label, 'click', @_onInputClick, @
		name = L.DomUtil.create 'span', '', span
		name.innerHTML = ' ' + obj.name

	_onResize: ->
		mapHeight = @_map.getContainer().clientHeight
		controlHeight = @_container.clientHeight
		@_container.style.overflowY = 'scroll' if controlHeight > mapHeight - @options.bottomPadding
		@_container.style.maxHeight = (mapHeight - @options.bottomPadding - @options.topPadding) + 'px'

	_onListScroll: ->
		minimaps = document.querySelectorAll "label[class='leaflet-minimap-container']"
		return  if minimaps.length is 0
		first = undefined
		last = undefined
		if @isCollapsed()
			first = last = -1
		else
			minimapHeight = minimaps.item(0).clientHeight
			container = @_container
			listHeight = container.clientHeight
			scrollTop = container.scrollTop
			first = Math.floor scrollTop / minimapHeight
			last = Math.ceil((scrollTop + listHeight) / minimapHeight)
		i = 0

		while i < minimaps.length
			minimap = minimaps[i].childNodes.item 0
			map = minimap._miniMap
			layer = map._layer
			continue unless layer
			if i >= first and i <= last
				layer.addTo map unless map.hasLayer layer
				map.invalidateSize()
			else
				map.removeLayer layer if map.hasLayer layer
			++i

	_onInputClick: ->
		i = undefined
		input = undefined
		obj = undefined
		inputs = @_form.getElementsByTagName 'input'
		inputsLen = inputs.length
		@_handlingClick = yes
		i = 0
		while i < inputsLen
			input = inputs[i]
			obj = @_layers[input.layerId]
			if input.checked and not @_map.hasLayer(obj.layer)
				@_map.addLayer obj.layer
			else @_map.removeLayer obj.layer if not input.checked and @_map.hasLayer(obj.layer)
			i++
		@_handlingClick = no
		@_refocusOnMap()

	_createMinimap: (mapContainer, originalLayer) ->
		minimap = mapContainer._miniMap = L.map mapContainer,
			attributionControl: no
			zoomControl: no
		
		# disable interaction.
		minimap.dragging.disable()
		minimap.touchZoom.disable()
		minimap.doubleClickZoom.disable()
		minimap.scrollWheelZoom.disable()
		
		# create tilelayer, but do not add it to the map yet.
		minimap._layer = L.layerGroup [
			_cloneLayer @options.backgroundLayer
			_cloneLayer originalLayer
		]
		
		map = @_map
		map.whenReady ->
			minimap.setView map.getCenter(), map.getZoom()
			map.sync minimap

L.control.layers.wxTilesMinimap = (layers, options) ->
	new L.Control.Layers.WXTilesMinimap(layers, options)