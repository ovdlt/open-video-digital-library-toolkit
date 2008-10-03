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

    $("div.template").addClass("hidden");

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

    $("div.display-edit div.edit").hide();

    $("div.display-edit span.edit a").click(function(){
        $("div.display, div.edit",$(this).parents("div.display-edit")[0]).toggle();
        return false;
    });

    $("div.display-edit span.delete a").click(function(){
        $($(this).parents("li.delete")[0]).remove();
        return false;
    });

    $("div.dt.display-new div.new").hide();

    $("div.dt.display-new a").click(function(){
        top = $($(this).parents("li.new")[0])
        cl = $("div.new > ul > li",top).clone();
        dtn = top.data("dt_count")
        if (dtn == null) {
            dtn = 0;
            top.data("dt_count",dtn);
        }
        dn = top.data("d_count")
        if (dn == null) {
            dn = 0;
            top.data("d_count",dn);
        }
        $("div.dt input",cl).each(function(){
            name = $(this).attr("name");
            name = name.replace("[new_dt]","[new_dt_"+dtn+"]")
            $(this).attr("name",name);

            $("div.d input",cl).each(function(){
                name = $(this).attr("name");
                name = name.replace("[new_dt]","[new_dt_"+dtn+"]");

                name = name.replace("[new_d]","[new_d_"+dn+"]");
                $(this).attr("name",name);
                dn++;
                top.data("d_count",dn);
            });

            dtn++;
            top.data("dt_count",dtn);

        });
        top.before(cl);
        $(".edit",cl).show();
        return false;
    });

    $("div.d.display-new a").click(function(){
        top = $($(this).parents("li.new")[0])
        cl = $("div.new > ul > li",top).clone();
        dn = top.data("d_count")
        if (dn == null) {
            dn = 0;
            top.data("d_count",dn);
        }
        $("div.d input",cl).each(function(){
            name = $(this).attr("name");
            name = name.replace("[new_d]","[new_d_"+dn+"]");
            $(this).attr("name",name);
            dn++;
            top.data("d_count",dn);
        });
        top.before(cl);
        $(".edit",cl).show();
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
            /* alert( $.cookie(".videos.list.partial.navigate.current") ); */

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

});
