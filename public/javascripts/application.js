$.ui.tabs.defaults.spinner = false;

$(document).ready(function(){

    $(".tabs > ul").tabs({ cookie: { expires: null } });

    $('.ui-tabs-nav').bind('tabsselect', function(event, ui) {
        $('.tabs form').ajaxSubmit({ async: false });
        return true;
    });


    $('.tabs').ajaxSuccess(function(){

        $('.tabs .pagination a').click(function(e){
            var $tabs = $(".tabs > ul").tabs();
            var selected = $tabs.data("selected.tabs");
            $tabs.tabs( "url", selected, e.target.href ).
                  tabs( "load", selected );
            return false;
        });


        $("#uncatted").autocomplete("/assets/uncataloged");

    });

});

