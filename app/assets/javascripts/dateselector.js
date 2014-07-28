// jQuery function to use jQuery UI Datepicker
// See http://api.jqueryui.com/datepicker
$(document).ready(function() {
    if ($("[id$=category_savings_goal_date]").length) {
        $.getScript('../assets/jquery-ui/datepicker.js', function() {
            $("[id$=category_savings_goal_date]").datepicker( {
                dateFormat: 'm/d/yy',
                changeMonth: true,
                changeYear: true,
                showOtherMonths: true
            });
        });
    }
});
