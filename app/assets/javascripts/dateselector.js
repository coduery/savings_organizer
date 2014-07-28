// jQuery function to use jQuery UI Datepicker
// See http://api.jqueryui.com/datepicker
$(document).ready(function() {
    if ($("[id$=category_savings_goal_date]").length) {
        $.getScript('//code.jquery.com/jquery-1.10.2.js');
        $.getScript('//code.jquery.com/ui/1.11.0/jquery-ui.js', function() {
            $("[id$=category_savings_goal_date]").datepicker( {
                dateFormat: 'm/d/yy',
                changeMonth: true,
                changeYear: true,
                showOtherMonths: true
            });
        });
    }
});
