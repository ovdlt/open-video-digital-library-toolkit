(function($){

    $.ui.tabs.defaults.spinner = false;

    $.load_assets = function(page,container){

        options = { "page": page };

        if (typeof(AUTH_TOKEN) != "undefined") {
            options.authenticity_token = AUTH_TOKEN;
        }

        "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);

        $.getJSON($.fn.paginate.load_path,options,function(data,status){

            row = $("div.uncataloged.template tr");
            tbody = $("tbody.page");

            /* could modify in place ... */

            tbody.empty();

            $.each(data,function(){
                c = row.clone();
                input = $("td.input input", c);
                input.attr("value",this.uri);
                a = $("a.uri", c);
                a.text(this.uri);
                $("td.format",c).text(this.asset_format);
                $("td.size",c).text(this.size);
                tbody.append(c);
            });

            $("tbody.page td.input a").click(function(e){
                row = $(this).parents("tr")[0];
                $("input",row).attr("name","new_assets[]");
                $("tbody.assets").append(row);
                return false;
            });


        });

    }

    $.fn.paginate = function(number,path){
        this.pagination(number,{
            callback: $.load_assets,
            items_per_page: 10
        });
        $.fn.paginate.load_path = path;
    }

    $(function(){

        $("ul.template").addClass("hidden");

        function edit() {

            // console.debug("edit");

            var ul = $(this).parents("ul")[0];
            var li = $(this).parents("li")[0];
            var template = $("ul.template li.delete",li)[0];
            var copy = $(template).clone();

            // could use a stored variable, but really ...
            var r = Math.floor(Math.random()*32768);

            $("[name]",copy).each(function() {

                name = $(this).attr("name");

                new_name = name.replace( /\[template_([^\]]+)\]/g, "[$1]" );

                if ( new_name != name ) {
                    name = new_name;
                } else {
                    name = name.replace( /\[(new(_[a-z]+)?)\]/g, "[$1_"+r+"]" );
                }

                $(this).attr("name",name);

                if ( v = $(this).attr("value") ) {
                    v = v.replace( /^(new(_[a-z]+)?)$/g, "$1_"+r+"" );
                    $(this).attr("value",v);
                }

            });

            $("div.property-type.new a",copy).each(edit);

            $(li).before(copy);
            $("div.display,span.display",copy).hide();
            $("div.edit,span.edit",copy).show();

            $("li.none",ul).hide();

            return false;
        };

        $("div.property-type.new a").live('click',edit);

        function edit_dt() {

            var div = $(this).parents(".new_dt")[0];
            var template = $("dl.delete",div)[0];
            // console.debug(template);
            var copy = $(template).clone();

            // could use a stored variable, but really ...
            var r = Math.floor(Math.random()*32768);

            $("[name]",copy).each(function() {

                name = $(this).attr("name");

                new_name = name.replace( /\[template_([^\]]+)\]/g, "[$1]" );

                if ( new_name != name ) {
                    name = new_name;
                } else {
                    name = name.replace( /\[(new(_[a-z]+)?)\]/g, "[$1_"+r+"]" );
                }

                $(this).attr("name",name);

                if ( v = $(this).attr("value") ) {
                    v = v.replace( /^(new(_[a-z]+)?)$/g, "$1_"+r+"" );
                    $(this).attr("value",v);
                }

            });

            $("div.property-type.new a",copy).each(edit);

            $(div).before(copy);

            $("div.display,span.display",copy).hide();
            $("div.edit,span.edit",copy).show();
            $(copy).show();

            return false;
        };


        $("div.property-type.new_dt a").live('click',edit_dt);

        $("div.template").addClass("hidden");

        /* make tab text red on panes with errors */
        $("a.tab").each(function(){
            id = $(this).attr("href");
            if ( $(id + " div.error").length > 0 ) {
                $("span",this).addClass("error");
            }
        });

        $(".assets.ajax").each(function(){

            row = $(".current.template tr");
            tbody = $("tbody.assets.ajax");

            $.each(tbody.data("assets"),function(){
                c = row.clone();
                input = $("td.input input", c);

                a = $("a.uri", c);
                a.text(this.uri);
                href = a.attr("href");
                $("td.format",c).text(this.asset_format);
                $("td.size",c).text(this.size);

                if( this.id == null ) {
                    input.attr("id","uncataloged_assests");
                    input.attr("value",this.uri);
                    input.attr("name","new_assets[]");
                    a.attr("href","javascript:return(false);");
                } else {
                    id = input.attr("id");
                    input.attr("id", id.replace(/:id:/,this.id));
                    input.attr("value", this.id);
                    a.attr("href",href.replace(/:id:/,this.id));
                }
                tbody.append(c);
            });

        });


        var tabs = [ ".tabs_pi", ".lt" ];

        $.each(tabs, function(k,v){
            $(v).tabs({ cookie: { expires: null,
                                  name: v.id } });
        });

        $("#uncatted").autocomplete("/assets/uncataloged.txt");

        function promote(uncatted) {
            uri = uncatted.attr("value");

            row = $(".current.template tr");
            tbody = $("tbody.assets.ajax");

            c = row.clone();
            input = $("td.input input", c);
            input.removeAttr("id");
            input.attr("name","new_assets[]");
            input.attr("value",uri);
            a = $("a.uri", c);
            a.text(uri);
            $("td.format",c).text("");
            $("td.size",c).text("");
            tbody.append(c);
            uncatted.attr("value",null);
        }

        $("#uncataloged_assets input[type=submit]").click(function(){
            promote( $("#uncatted") );
            return false;
        });

        $("#uncatted").keypress(function(e){
            if(e.which == 13){
                uri = $(this).attr("value");

                row = $(".current.template tr");
                tbody = $("tbody.assets.ajax");

                c = row.clone();
                input = $("td.input input", c);
                input.removeAttr("id");
                input.attr("name","new_assets[]");
                input.attr("value",uri);
                a = $("a.uri", c);
                a.text(uri);
                $("td.format",c).text("");
                $("td.size",c).text("");
                tbody.append(c);
                $(this).attr("value",null);
                return false;
            }
            return true;
        });

        $(".assets tr .delete a").live('click',function(e){
            $($(this).parents("tr")[0]).remove();
            return false;
        });


        $("form label.button").hover(function(){
            $(this).addClass("pointer");
        },function(){
            $(this).removeClass("pointer");
        })
        /* Firefox doesn't need this but IE does */
            .click(function(){
                $("input",this).click();
                return false;
            });

        // Site Activity page
        $('.activity-toggle a').click(function(){
            // TODO improve to remove multiple parent traversal
            $(this).parent().parent().parent().parent().find('table').toggle();
            var thisElem = $(this);
            thisElem.text(thisElem.text() === "[show]" ? "[hide]" : "[show]");
            return false;
        });

        $("a.storyboard_image").fancybox();

        $("div.bookmark.hidden").hide();

        $("label.button.playlist").click(function(){
            $("div.bookmark.hidden",$(this).parents("form")).toggle();
        });

        $("div.video_embed.hidden").hide();

        $("label.button.video_embed_area").click(function(){
            $("div.video_embed.hidden",$(this).parents("form")).toggle();
        });

        $("form .display-edit div.display.error").hide();

        $("form .display-edit > div.edit").hide();
        $("form .display-edit > span.edit").hide();
        $("form .display-edit > div.edit.error").show();
        $("form .display-edit > span.edit.error").show();

        $("form .display-edit .dt_handle span.edit a").click(function(){
            // console.debug("edit");
            $("div.display, div.edit, span.display, span.edit",$(this).parents(".display-edit")[0]).toggle();
            return false;
        });

        // Duplicate of block above but changed the ".dt_handle" to".dv_handle"
        // and added /dv_handle class to libary/_dv.html partial
        // Best temp solution to make editing/deleting values in both dt and dv work
        $("form .display-edit .dv_handle span.edit a").click(function(){
            // console.debug("edit");
            $("div.display, div.edit, span.display, span.edit",$(this).parents(".display-edit")[0]).toggle();
            return false;
        });

        $("form .display-edit span.delete a").live('click',function(){
            // console.debug("delete");
            // not really a ul anymore ...
            ul = $(this).parents("ul, dt")[0];
            var top = $($(this).parents("li.delete, dt.delete")[0]);
            // console.debug( "smp" );
            // console.debug(top);
            $("input.deleted[type=hidden]",top).attr("value","deleted");
            top.hide();

            top.next("dd").hide();

            if ( $("li.delete:visible", ul).length == 1 ) {
                $("li.none").show();
            }

            return false;
        });

        /* video list buttons */

        var current_button_class =
            $.cookie(".videos.listby.current");
        if ( current_button_class == null) {
            current_button_class = "big_thumbs";
            $.cookie(".videos.listby.current",
                     current_button_class,
                     { path: '/' }
                    );
        }

        $(".videos").removeClass("big_thumbs");
        $(".videos").removeClass("text_only");
        $(".videos").removeClass("sm_thumbs");
        $(".videos").removeClass("thumbs_only");
        $(".videos").addClass(current_button_class);

        $(".videos .listby .button").each(function(){
            if($(this).hasClass(current_button_class)){
                $(this).addClass("current");
                $(this).removeClass("pointer");
            } else {
                $(this).removeClass("current");
                $(this).addClass("pointer");
            }
        });

        $(".videos .button").click(function(){
            var clicked = this;
          $("div.button",$(clicked).parents("div.listby")[0]).each(function(){
                if(this == clicked){

                    var classes = $(this).attr("class").split(" ");
                    current = $.grep( classes, function(n){
                        return n != "button" && n != "current" && n != "pointer"
                    })[0];
                    $.cookie(".videos.listby.current",
                             current,
                             { path: '/' }
                            );

                    $(".videos").removeClass("big_thumbs");
                    $(".videos").removeClass("text_only");
                    $(".videos").removeClass("sm_thumbs");
                    $(".videos").removeClass("thumbs_only");
                    $(".videos").addClass(current);

                    $(this).addClass("current");
                    $(this).removeClass("pointer");
                } else {
                    $(this).removeClass("current");
                    $(this).addClass("pointer");
                }
            });
        });

        $("li.print a").click(function(){
            window.print();
            return false;
        });

        $("span.next input, input[name=next]").click(function(){
            tabs = $(".tabs_pi > ul").tabs();
            current = tabs.data('selected.tabs');
            if( current+2 == tabs.tabs('length') ) {
                $("span.next input").hide();
            }
            tabs.tabs('select',current+1);
            return false;
        });

        $("form .button.save_query a").click(function(){
            var form = $(this).parents("form")[0];
            $(".hidden",form).show();
            return false;
        });

        $("div.featured input[type=checkbox]").click(function(){
            $(this).parents("form")[0].submit();
        });

        $("div.public input[type=checkbox]").click(function(){
            $(this).parents("form")[0].submit();
        });

        $("div.back input").click(function(){
            history.go(-1);
            return false;
        });


        $("div#content div.axis").click(function(){
            // console.debug("click");
            $("body").css("cursor","wait");
            pt_id = $(this).attr("id").replace("property_type_","");
            $.get(relative_url_root + "/videos/images?property_type=" + pt_id, function(data){
                $("div#browse div.videos").fadeOut("fast",function(){
                    $("div#browse div.videos").html(data);
                    $("div#browse div.videos").fadeIn("fast");
                    $("body").css("cursor","default");
                });
            });
        });

        $("div.poster.check").css("cursor","pointer");
        $("div.poster.check").click(function(){
            $("form",this).submit();
        });

    });

    /* Function to make a list (of collections, videos, etc) sortable
 * Parameters:
 *  list_selector - div id or other selector for the list that will become sortable
 *  item_selector - what elements should be draggable within this list
 *  post_url      - URL to POST changes to be saved on the server
 *    accepts a selector (div id, etc) and applies jQuery Sortable to it
 */
    make_sortable = function( options )
    {
        var list_selector = options.list_selector;
        var item_selector = options.item_selector;
        var post_url      = options.post_url;
        var handle        = (undefined == options.handle ) ? ".handle" : options.handle ;
        var cancel        = options.cancel;

        //console.log("Making this list sortable --> " + list_selector );
        //console.log("                       items are '" + item_selector + "'" );

        //console.log("                    : cancel is [" + cancel + "]" );
        //console.log("                    : handle is [" + handle + "] -- options.handle = [" + options.handle + "]" );

        $(list_selector + " " + item_selector).bind("mouseover",
                                                    function(e) {
                                                        $(".ui-sortable .handle").hide();
                                                        $(this).children(".handle").show()
                                                    } );

        // TODO generalize this
        $(list_selector).bind("mouseout", function(e) { $("#content .collection .handle").hide() } );
        //console.log("                    : mouseover bindings complete");

        $(list_selector).sortable({
            items: item_selector,
            // SMP: locking to the axis causes wierd jumps (padding/margins?)
            // axis: 'y',
            cancel: cancel,
            revert: true,
            cursor: 'move',
            placeholder : "placeholder",
            //tolerance: 'intersect',
            handle: handle,
            containment: 'document',
            update: function() {
                var new_order = get_sortable_order(list_selector) ;
                // console.log( "Sortable: " + list_selector + " -- new order:  " + new_order );
                // console.log( "Sortable: " + list_selector + " -- old order:  " + $(list_selector).attr("original_order") );
                if (($(list_selector).attr("original_order") != new_order))
                {
                    // $(".save_new_order").fadeIn(250);
                    // $(".save_new_order").effect("highlight", {}, 2000 );
                    send_new_order( list_selector, post_url, new_order );
                }
            }
        });

        //console.log("                    : sortable complete");

        var orig_order =get_sortable_order(list_selector) ;
        $(list_selector).attr("original_order", orig_order );
        //console.log("                    : saved original order [" + orig_order + "]");
        // $(".save_new_order").bind("click", send_new_order);
    }

    get_sortable_order = function( list )
    {
        // console.debug( list);
        // console.debug( $(list) );
      return $( list ).sortable('serialize').replace( /&[a-z_]+\[\]=/ig, ",").replace( /[a-z_]+\[\]=/i, "");
    }

    send_new_order = function( list, post_url, new_order ) {
        // disable the sortable list until we receive confirmation from the server that new order was saved
        $(list).sortable('disable');

        //console.log("order to send is " + new_order );

        var post_data = "order=" + new_order
            + "&authenticity_token=" + encodeURIComponent(AUTH_TOKEN);

        // jQuery.post("http://localhost:3000/collections/featured/order", post_data, new_order_saved, "text" );
        // console.log("full post url is " + relative_url_root + post_url );

        jQuery.ajax( {
            url: relative_url_root + post_url,
            type: "POST",
            success: new_order_saved(list),
            error: failed_saving_new_order,
            dataType: "text",
            data: post_data
        });
        //console.log("Sent data: " + post_data );
    };

    new_order_saved = function( selector )
    {
        list = $(selector);
        var sent_order = get_sortable_order( selector );
        return  function ( data, textstatus ) {
            //console.log( "status = " + textstatus );
            if ( textstatus == "success" ) {
                //console.log("success saving order");
                // save the new order for this list
                list.attr("original_order", sent_order );
                // $(".save_new_order").fadeout(500);
                // re-enable the sortable, now that new order is saved on the server
                list.sortable('enable');
            }
        };
    };

    failed_saving_new_order = function( xml_req, error, exception )
    {
        //console.log("failed sending new order to server");
        // TODO display a message telling the user we failed saving the order and what they can do about it ?
    };

    $(function(){
        $(".annotation .edit").each(function(){
            var blur = function(){
                var s = $(this).text();
                if(s === "") {
                    $(this).text(s = "Click to add annotation (press Enter to save)");
                }
                if(s === "Click to add annotation (press Enter to save)"){
                    $(this).addClass("default");
                } else {
                    $(this).removeClass("default");
                }
            };
            $(this).blur(blur);
            blur.apply(this);
            $(this).focus(function(){
                var i = $(this).find("input");
                var s = i.val();
                if(s === "Click to add annotation (press Enter to save)"){
                    i.val("");
                }
                return false;
            });
            var url = $(this).parent().find(".url").text();
            $(this).editable(url, {
                tooltip: "Click to edit ...",
                method: "PUT",
                callback: function(){
                    blur.call(this);
                },
            });
        });
    });

})(jQuery);

// Local Variables:
// espresso-indent-level:4
// c-basic-offset:4
// tab-width:4
// End: