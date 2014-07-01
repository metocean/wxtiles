var satoverlay=null;
var wxoverlay=null;
var active=null;

function add_wm_wxtiles(dt){
    var centerpos=null;
    var zoom=null;
    var latlng=null;
    
    //map options
    var options = {
        zoom: 5,
        center: centerpos,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        mapTypeControl: false,
        navigationControl: true,
        streetViewControl: false,
        navigationControlOptions: {
            style: google.maps.NavigationControlStyle.ZOOM_PAN
        }
    };
    //create google maps object
    map = new google.maps.Map(document.getElementById("map"), options);
    //create wxtiles satellite object
    wxoverlay = new WXTiles({withnone:true,autoupdate:false,cview:"satir",updateCallback:loadTimes});
    map.id='charts-map';
    //add new satellite and weather objects to map
    wxoverlay.addToMap(map);
    //add legend color bar
    wxoverlay.addColorBar('small', 'horiz');
    map.setCenter(new google.maps.LatLng(-41.10, 172.28));
    map.setZoom(5);
    return map;
}

function update_view(dt) {
    wxoverlay.setView(dt);
    loadTimes(wxoverlay, dt);
}

//Wrapper function to update time of layer -> setTime() will automatically update the overlay weather/satellite tiles
function wx_change_time(t) { wxoverlay.setTime(t); }

/*
    The loadTimes function is to add all times down the side in a menu form.
    Its easier to use a dropdown box because the wxtiles api does this automatically.
    However, this function provides an example of how the times can be retrieved and presented in
    a different way. To access all times use the api function getTimes() 
    
*/
function loadTimes() {
    var timesel = $("#times");
    var times=wxoverlay.getTimes(wxoverlay.cview, false)
    var tar = [];
    var ftime=null;
    var thtml="";
    
    timesel.html("");
      
    $.each(times, function(i, value) {
        var tstr=new Date(times[i]);
        if (wxoverlay.ctime==times[i]) {
            tar[i]='<li class="sel"><a class="time-link time-sel" rel="'+times[i]+'">'+getJSTime(times[i])+'</a></li>';
            ftime=times[i];
        }
        else {
            tar[i]='<li><a class="time-link" rel="'+times[i]+'">'+getJSTime(times[i])+'</a></li>';
        }
    });
    
    if (!ftime) {
        tar[tar.length-1]='<li class="sel"><a class="time-link time-sel" rel="'+times[tar.length-1]+'">'+getJSTime(times[tar.length-1])+'</a></li>';
        ftime=times[tar.length-1];
    }
    
    $.each(tar, function(index, value) { thtml+=value; });
    timesel.append(thtml);
    
    $(".time-link").bind("click", function() {
        remove_selected_item();
        add_selected_item($(this).attr('rel'));
        wx_change_time($(this).attr('rel'));
        $(".step-date").html($(this).html());
    });
    $(".step-date").html($(".time-sel").html());
    
    wx_change_time(ftime);
}

function getJSTime(t) {
    var nd=new Date(t);
    return datedays[nd.getDay()]+' '+nd.getDate()+' '+datemonths[nd.getMonth()]+' '+zer0(nd.getHours())+':'+zer0(nd.getMinutes());
}

/*
    All function below use jquery to update selected time on the right menu
  
*/

function remove_selected_item() {
    $(".time-link").each(function() {
        if ($(this).hasClass('time-sel')) {
            $(this).removeClass('time-sel');
            $(this).parent().removeClass('sel');   
        }
    });
}

function add_selected_item(t) { $('[rel='+t+']').addClass('time-sel').parent().addClass('sel'); }

function update_selected_item(t) {
    remove_selected_item();
    add_selected_item(t);
}

function step_time_forward() {
    var el=$('.sel').next().children('.time-link');
    var t = el.attr('rel');
    step_time(t);
}

function step_time_back() {
    var el=$('.sel').prev().children('.time-link');
    var t = el.attr('rel');
    step_time(t);
}

function step_time(t) {
    if (t) {
        wx_change_time(t);
        update_selected_item(t);
    }
    $(".step-date").html($(".time-sel").html());
}
