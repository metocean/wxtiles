function add_ol_wxtiles(){
    var options = {
    controls: [],
    projection: new OpenLayers.Projection("EPSG:900913"),
    displayProjection: new OpenLayers.Projection("EPSG:4326"),
    units: "m",
    maxResolution: 156543.0339,
    maxExtent: new OpenLayers.Bounds(-20037509, -20037508.34, 20037508.34, 20037508.34)
    };
    var map = new OpenLayers.Map('map', options);

    var baselayer=new OpenLayers.Layer.OSM();

    var satoverlay=new WXTiles({withnone:true,autoupdate:true,cview:'none',vorder:['none','satir','satenh']});
    var wxoverlay=new WXTiles({withnone:true,autoupdate:true,cview:'rain',vorder:['rain','wind','tmp','hs','tp','sst']});
    map.addLayers([baselayer]);
    wxoverlay.addToMap(map);
    satoverlay.addToMap(map);
    wxoverlay.addColorBar('small','horiz');

    document.getElementById('tSelect').appendChild(wxoverlay.getTSelect());
	document.getElementById('wxSelect').appendChild(wxoverlay.getVSelect());
	document.getElementById('satSelect').appendChild(satoverlay.getVSelect());
    
    wxoverlay.linkTime(satoverlay);
    
    map.addControl(new OpenLayers.Control.PanZoomBar());
    map.addControl(new OpenLayers.Control.NavToolbar());
    map.addControl(new OpenLayers.Control.KeyboardDefaults());

    return map;
}
