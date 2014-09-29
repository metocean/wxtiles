# # Leaflet.layerscontrol-minimap
# 
# Layers control with synced minimaps for Leaflet.
# Jan Pieter Waagmeester <jieter@jieter.nl>
# Enhancements by Thomas Coats <thomas@metocean.co.nz>

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

L.Control.Layers.Minimap = L.Control.Layers.extend
  options:
    position: 'topright'
    topPadding: 10
    bottomPadding: 40
    overlayBackgroundLayer: L.tileLayer 'http://a{s}.acetate.geoiq.com/tiles/acetate-base/{z}/{x}/{y}.png',
      attribution: '&copy;2012 Esri & Stamen, Data from OSM and Natural Earth'
      subdomains: '0123'
      minZoom: 2
      maxZoom: 18

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
    L.Control.Layers::_expand.call this
    @_onListScroll()

  _initLayout: ->
    L.Control.Layers::_initLayout.call this
    L.DomUtil.addClass @_container, 'leaflet-control-layers-minimap'
    L.DomEvent.on @_container, 'scroll', @_onListScroll, this

  _update: ->
    L.Control.Layers::_update.call this
    @_map.on 'resize', @_onResize, this
    @_onResize()
    @_map.whenReady @_onListScroll, this

  _addItem: (obj) ->
    container = if obj.overlay then @_overlaysList else @_baseLayersList
    label = L.DomUtil.create 'label', 'leaflet-minimap-container', container
    label._layerName = obj.name
    checked = @_map.hasLayer obj.layer
    @_createMinimap L.DomUtil.create('div', 'leaflet-minimap', label), obj.layer, obj.overlay
    span = L.DomUtil.create 'span', 'leaflet-minimap-label', label
    input = undefined
    if obj.overlay
      input = document.createElement 'input'
      input.type = 'checkbox'
      input.className = 'leaflet-control-layers-selector'
      input.defaultChecked = checked
    else
      input = @_createRadioElement 'leaflet-base-layers', checked
    input.layerId = L.stamp obj.layer
    span.appendChild input
    L.DomEvent.on label, 'click', @_onInputClick, this
    name = L.DomUtil.create 'span', '', span
    name.innerHTML = ' ' + obj.name
    label

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

  _createMinimap: (mapContainer, originalLayer, isOverlay) ->
    minimap = mapContainer._miniMap = L.map mapContainer,
      attributionControl: no
      zoomControl: no
    
    # disable interaction.
    minimap.dragging.disable()
    minimap.touchZoom.disable()
    minimap.doubleClickZoom.disable()
    minimap.scrollWheelZoom.disable()
    
    # create tilelayer, but do not add it to the map yet.
    if isOverlay
      minimap._layer = L.layerGroup [
        _cloneLayer @options.overlayBackgroundLayer
        _cloneLayer originalLayer
      ]
    else
      minimap._layer = _cloneLayer originalLayer
    map = @_map
    map.whenReady ->
      minimap.setView map.getCenter(), map.getZoom()
      map.sync minimap

L.control.layers.minimap = (baseLayers, overlays, options) ->
  new L.Control.Layers.Minimap(baseLayers, overlays, options)