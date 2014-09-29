L.WXTileLayer = L.TileLayer.extend
	options:
		minZoom: 0
		maxZoom: 17
		tms: yes
		
		# We are duplicating these default from TileLayer as they don't get inherited.
		subdomains: 'abc'
		zoomOffset: 0
	
	setUrl: undefined
	
	initialize: (config, options) ->
		@_config = config
		
		# Select the first field available
		@setField @_config.fields[0], no
		
		# Select the closest future date if the key is a time dimension.
		if @_config.keyistime
			now = new Date()
			initialkey = null
			for key in @_config.keys
				initialkey = key
				break if key.time > now
			@setKey initialkey, no
		else
			@setKey @_config.keys[0], no
		
		L.TileLayer.prototype.initialize.call @, '[wxtiles]/{z}/{x}/{y}.png', options

	getConfig: ->
		@_config

	setKey: (key, noRedraw) ->
		@_key = key
		@redraw() if !noRedraw? or !noRedraw
		@
	
	getKey: ->
		@_key
	
	setField: (field, noRedraw) ->
		@_field = field
		@setOpacity field.defaultalpha
		@redraw() if !noRedraw? or !noRedraw
		@
	
	getField: ->
		@_field
	
	back: (noRedraw) ->
		index = @_config.keys.indexOf @_key
		index--
		index %= @_config.keys.length
		@setKey @_config.keys[index], noRedraw
	
	forward: (noRedraw) ->
		index = @_config.keys.indexOf @_key
		index++
		index %= @_config.keys.length
		@setKey @_config.keys[index], noRedraw

	getTileUrl: (coords) ->
		L.TileLayer.prototype.getTileUrl
			.call @, coords
			.replace /\[wxtiles\]/,
				"#{@_config.url}tile/#{@_config.cycle}/#{@_field.name}/#{@_key.name}"

L.wxTileLayer = (config, field, options) ->
	new L.WXTileLayer config, field, options