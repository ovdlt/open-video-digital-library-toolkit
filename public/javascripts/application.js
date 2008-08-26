$.ui.tabs.defaults.spinner = false;

$(document).ready(function(){

    $(".tabs > ul").tabs({ cookie: { expires: null } });

    $('.ui-tabs-nav').bind('tabsselect', function(event, ui) {
        $('.tabs form').ajaxSubmit({ async: false });
        return true;
    });


    $('.tabs').ajaxSuccess(function(){

        $('.tabs .pagination a').click(function(){
            alert("not implemented (yet?)");
            return false;
        });

        $("#uncatted").autocomplete("/assets/uncataloged");

    });

    $('.tabs').ajaxError(function(event,request,settings){
        /* $('.flash.errors') =  */
        alert("bogus " + request.responseText);
    });

});

