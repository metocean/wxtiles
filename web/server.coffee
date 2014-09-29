http = require 'http'
url = require 'url'
path = require 'path'
httpProxy = require 'http-proxy'

maps =
	open: url.parse 'http://wx.wxtiles.com/'
	wx: url.parse 'http://tiles.metoceanview.com/wx/'
	sv: url.parse 'http://tiles.metoceanview.com/sv/'
	clim: url.parse 'http://tiles.metoceanview.com/clim/'
	hc: url.parse 'http://tiles.metoceanview.com/hc/'

proxy = httpProxy.createProxyServer()
proxy.on 'proxyReq', (p, req, res, options) ->
	p.setHeader 'host', req.host if req.host?

mapapi = (target, pathchunks) ->
	pathchunks.reverse()
	pathchunks.pop()
	pathchunks.pop()
	pathchunks.pop()
	pathchunks.push ''
	pathchunks.reverse()
	pathchunks.join '/'

http
	.createServer (req, res) ->
		source = url.parse req.url
		path = source.pathname
		chunks = source.pathname.split '/'
		
		if chunks.length < 4 or !maps[chunks[2]]?
			res.writeHead 404, 'Content-Type': 'text/plain'
			res.write '404 Not found'
			res.end()
			return
		
		apikey = chunks[1]
		api = chunks[2]
		
		target = maps[api]
		path = mapapi target, chunks
		path += source.search if source.search?
		source = url.parse path
		
		console.log source.href
		
		req.url = source.href
		req.host = target.host
		proxy.web req, res, target: target.href
	.listen 8008