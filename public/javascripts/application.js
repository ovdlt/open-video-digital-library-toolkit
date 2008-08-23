$.ui.tabs.defaults.spinner = false;
/* $.ui.tabs.defaults.fx =  { opacity: 'toggle', duration: 10000 } */

$(document).ready(function(){

    $(".tabs > ul").tabs();

    $('.ui-tabs-nav').bind('tabsselect', function(event, ui) {
        $('.tabs form').ajaxSubmit({ async: false });
        return true;
    });

});

