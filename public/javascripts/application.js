$.ui.tabs.defaults.spinner = false;
/* $.ui.tabs.defaults.fx =  { opacity: 'toggle', duration: 10000 } */

$(document).ready(function(){

    $(".tabs > ul").tabs({ cookie: { expires: null } });

    $('.ui-tabs-nav').bind('tabsselect', function(event, ui) {
        $('.tabs form').ajaxSubmit({ async: false });
        return true;
    });


    $('.tabs').ajaxSuccess(function(){
        $('.tabs .pagination a').click(function(){
            alert("click");
            return false;
        });
    });

    $('.tabs').ajaxError(function(event,request,settings){
        /* $('.flash.errors') =  */
        alert("bogus " + request.responseText);
    });

});

