wxformats =
	'%Y': -> @.getFullYear()
	'%y': -> @.getFullYear().substr 2, 2
	'%B': -> wxformat.monthNames[@.getUTCMonth()]
	'%b': -> wxformat.monthNames[@.getUTCMonth()].substr 0, 3
	'%m': -> wxformat.padzero @.getUTCMonth() + 1
	'%A': -> wxformat.dayNames[@.getUTCDay()]
	'%a': -> wxformat.dayNames[@.getUTCDay()].substr 0, 3
	'%d': -> wxformat.padzero @.getUTCDate()
	'%e': -> @.getUTCDate()
	'%h': -> wxformat.padzero if h = @.getUTCHours() % 12 then h else 12
	'%H': -> wxformat.padzero @.getUTCHours()
	'%M': -> wxformat.padzero @.getUTCMinutes()
	'%S': -> wxformat.padzero @.getSeconds()
	'%p': -> if @.getUTCHours() < 12 then 'a' else 'p'

wxformat =
	monthNames: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
	dayNames: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
	padzero: (str) -> if String(str).length < 2 then "0#{str}" else str
	formats: wxformats
	keys: new RegExp (key for key, _ of wxformats).join('|'), 'g'

Date::wxformat = (f) ->
	return '' unless @valueOf()
	f.replace wxformat.keys, (match) => wxformat.formats[match].call @

#callback=init1409532201851&domain=metoceanview.com
initservers = [
	'http://wx.wxtiles.com/'
	'http://tiles.metoceanview.com/wx/'
]

tileservers = [
	'http://sat.metoceanview.com/tile/'
	'http://tiles.metoceanview.com/wx/'
	'http://tiles.metoceanview.com/sv/'
	'http://tiles.metoceanview.com/clim/'
	'http://tiles.metoceanview.com/hc/'
]

class wxtiles
	loadConfiguration: (url, domain, cb) =>
		host = url.replace /{s}/, 'a'
		$.getJSON "#{host}tile/init?domain=#{domain}&callback=?", (data) =>
			keyset = []
			keyistime = !data.timekey?
			
			parseKeys = (keys) ->
				if keyistime
					for time in keys
						time = new Date "#{time.replace(' ', 'T')}Z"
						time: time
						name: time.wxformat '%Y%m%d_%Hz'
						description: time.wxformat '%Y-%m-%d %H%M'
				else
					for k in keys
						name: k
						description: data.timekey[k]
			
			result =
				url: url
				domain: domain
				cycle: data.cycle
				fields: for name, description of data.views
					keyset = keyset.concat data.times[name]
					name: name
					description: description
					defaultalpha: data.defalpha[name]
					keys: parseKeys data.times[name]
			
			# keep only unique keys
			keyset = keyset.filter (val, i, arr) -> i <= arr.indexOf val
			result.keys = parseKeys keyset
			result.keyistime = keyistime
			
			cb result if cb?

# Export this class as a global, amd module or commonjs module
if typeof module is 'object' and typeof module.exports is 'object'
	module.exports = new wxtiles()
else if typeof define is 'function' and define.amd
	define new wxtiles()
else if window?
	window.wxtiles = new wxtiles()