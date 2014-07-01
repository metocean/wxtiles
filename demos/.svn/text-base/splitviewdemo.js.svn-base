var rain, wind, temp, wave;
var wx1, wx2, wx3, wx4;

function updateTime(time, up) {
    var t=parseInt(time);
    t = (up) ? (t+1600000) : (t-1600000);
    wx1.setTime(t);
}

function make_splitdemo() {
    var wvars=["rain", "wind", "tmp", "hs"];
    var latlng=null;
    
    var mapOptions = {
        zoom: 4,
        center: new google.maps.LatLng(-41.10, 172.28),
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    
    var rainOptions = {
        zoom: 4,
        center: new google.maps.LatLng(-41.10, 172.28),
        mapTypeId: google.maps.MapTypeId.SATELLITE
    };
    
    wx1=new WXTiles({name:'Rain',withnone:false,autoupdate:true,cview:"rain"});
    var map1=new google.maps.Map(document.getElementById('rain'), rainOptions);
    map1.id='rain';
    wx1.addToMap(map1);
    
    
    wx2=new WXTiles({name:'Wind',withnone:false,autoupdate:true,cview:"wind"});
    var map2=new google.maps.Map(document.getElementById('wind'), mapOptions);
    map2.id='wind';
    wx2.addToMap(map2);
    
    wx3=new WXTiles({name:'Temperature',withnone:false,autoupdate:true,cview:"tmp"});
    var map3=new google.maps.Map(document.getElementById('temp'), mapOptions);
    map3.id='temp';
    wx3.addToMap(map3);
    
    wx4=new WXTiles({name:'Wave height',withnone:false,autoupdate:true,cview:"hs"});
    var map4=new google.maps.Map(document.getElementById('wave'), mapOptions);
    map4.id='hs';
    wx4.addToMap(map4);

    document.getElementById('Select').appendChild(wx1.getTSelect());
    wx1.linkTime(wx2);
    wx1.linkTime(wx3);
    wx1.linkTime(wx4);
}
