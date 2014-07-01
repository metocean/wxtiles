function add_gm_wxtiles(){
	var options = {
	  zoom: 4,
	  center: new google.maps.LatLng(40, 0),
	  mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	var map = new google.maps.Map(document.getElementById("map"),options);

	var satoverlay=new WXTiles({withnone:true,autoupdate:true,cvar:'satir'});
	var wxoverlay=new WXTiles({withnone:true,autoupdate:true,cvar:'rain'});
	wxoverlay.addToMap(map);
	satoverlay.addToMap(map);
	wxoverlay.addColorBar('big','horiz');

	document.getElementById('tSelect').appendChild(wxoverlay.getTSelect());
	document.getElementById('wxSelect').appendChild(wxoverlay.getVSelect(['rain','wind','tmp','hs','tp','sst']));
	document.getElementById('satSelect').appendChild(satoverlay.getVSelect(['satir','satenh','satvis']));

	wxoverlay.linkTime(satoverlay);
    }
