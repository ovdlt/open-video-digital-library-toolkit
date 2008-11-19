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
        $("div.display",copy).hide();
        $("div.edit",copy).show();

        $("li.none",ul).hide();

        return false;
    };

    $("div.property-type.new a").livequery('click',edit);

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
            id = input.attr("id");
            input.attr("id", id.replace(/:id:/,this.id));
            input.attr("value", this.id);
            a = $("a.uri", c);
            a.text(this.uri);
            href = a.attr("href");
            a.attr("href",href.replace(/:id:/,this.id));
            $("td.format",c).text(this.asset_format);
            $("td.size",c).text(this.size);
            tbody.append(c);
        });

    });


    $(".tabs > ul").tabs({ cookie: { expires: null } });

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

    $(".assets tr .delete a").livequery('click',function(e){
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

    $("div.bookmark.hidden").hide();

    $("label.button.playlist").click(function(){
        $("div.bookmark.hidden",$(this).parents("form")).toggle();
    });

    $("div.display-edit div.display.error").hide();

    $("div.display-edit div.edit").hide();
    $("div.display-edit div.edit.error").show();

    $("div.display-edit span.edit a").click(function(){
        $("div.display, div.edit",$(this).parents("div.display-edit")[0]).toggle();
        return false;
    });

    $("div.display-edit span.delete a").livequery('click',function(){
        ul = $(this).parents("ul")[0];
        var top = $($(this).parents("li.delete")[0]);
        $("input.deleted[type=hidden]",top).attr("value","deleted");
        top.hide();

        if ( $("li.delete:visible", ul).length == 1 ) {
            $("li.none").show();
        }

        return false;
    });

    /* video list buttons */

    var current_button_class =
        $.cookie(".videos.list.partial.navigate.current");
    if ( current_button_class == null) {
        current_button_class = "bg_thumbs";
        $.cookie(".videos.list.partial.navigate.current",
                 current_button_class,
                 { path: '/' }
                );
    }

    $(".videos.list.partial").removeClass("bg_thumbs");
    $(".videos.list.partial").removeClass("text_only");
    $(".videos.list.partial").removeClass("sm_thumbs");
    $(".videos.list.partial").removeClass("sm_thumbs_only");
    $(".videos.list.partial").addClass(current_button_class);

    $(".videos.list.partial .navigate .button").each(function(){
        if($(this).hasClass(current_button_class)){
            $(this).addClass("current");
            $(this).removeClass("pointer");
        } else {
            $(this).removeClass("current");
            $(this).addClass("pointer");
        }
    });

    $(".videos.list.partial .navigate .button").click(function(){
        var clicked = this;
        $("div.button",$(clicked).parents("div.navigate")[0]).each(function(){
            if(this == clicked){

                var classes = $(this).attr("class").split(" ");
                current = $.grep( classes, function(n){
                    return n != "current" && n != "pointer"
                })[0];
                $.cookie(".videos.list.partial.navigate.current",
                         current,
                         { path: '/' }
                        );

                $(".videos.list.partial").removeClass("bg_thumbs");
                $(".videos.list.partial").removeClass("text_only");
                $(".videos.list.partial").removeClass("sm_thumbs");
                $(".videos.list.partial").removeClass("sm_thumbs_only");
                $(".videos.list.partial").addClass(current);

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

    $("span.next input").click(function(){
        tabs = $(".tabs > ul").tabs();
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

});
