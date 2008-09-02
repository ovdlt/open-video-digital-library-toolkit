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


});

