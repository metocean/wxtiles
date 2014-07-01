/*
 *  WXTiles - JQuery plugin for providing marine weather for Google Maps and OpenLayers
 *  Version: 1.0.1
 *  Copyright (c) 2011 MetOcean Solutions Ltd
 *
 *  See our terms and conditions of use at http://www.wxtiles.com/terms-and-conditions/
 *
 */

(function($) { 
    var wxoverlay = null;
    var methods = {
        init: function(opts) {
            var that=this;
            var options = $.extend({}, defaults, opts);
            $.getScript('http://www.wxtiles.com/api/jsapi', function() {
                return that.each(function() {
                    var $e = $(this);
                    if (!$e.hasClass('wxtiles-plugin')) $e.addClass('wxtiles-plugin');
                    var header=$('<div>').attr({id:"wxtiles-header"});
                    var mapdiv=$('<div>').attr({id:"wxtiles-map"}).css({'height':'95%','border':'1px'});
                    $e.append(header).append(mapdiv);
                    
                    var map = new google.maps.Map(mapdiv.get(0), {
                        zoom: options.zoom,
                        center: options.center,
                        mapTypeId: options.maptype
                    });
                    wxoverlay=new WXTiles({
                        'cview': options.cview,
                        'ctime': options.ctime,
                        'autoupdate': options.autoupdate,
                        'withnone': options.withnone,
                        'vorder': options.vorder
                    });
                    wxoverlay.addToMap(map);
                    if (options.colorbar) wxoverlay.addColorBar(options.colorbar_size, options.colorbar_ori, options.colorbar_pos);
                    if (options.time_selector) $('#wxtiles-header').append(wxoverlay.getTSelect());
                    if (options.view_selector) $('#wxtiles-header').append(wxoverlay.getVSelect());
                });
            });
        }
    }
    
    var defaults = {
        zoom: 3,
        center: new google.maps.LatLng(40, 0),
        maptype: google.maps.MapTypeId.ROADMAP,
        cview: 'rain',
        ctime: null,
        withnone: false,
        autoupdate: false,
        colorbar: true,
        time_selector: true,
        view_selector: true,
        colorbar_size: 'small',
        colorbar_ori: 'horiz',
        colorbar_pos: 'TopRight'
    };
    
    $.fn.wxtiles = function(method) {
        // Method calling logic
        if ( typeof method === 'object' || ! method ) {
            return methods.init.apply( this, arguments );
        }
        else if (wxoverlay[method]) {
            return wxoverlay[method].apply(wxoverlay, Array.prototype.slice.call( arguments, 1 ));
        }
        else if ( methods[method] ) {
            return methods[ method ].apply( this, Array.prototype.slice.call( arguments, 1 ));
        }
        else {
            $.error( 'Method ' +  method + ' does not exist in jQuery.wxtiles.' );
        }   
    };

})(jQuery);
