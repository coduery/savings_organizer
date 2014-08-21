// jQuery function to use jQuery UI Datepicker
// See http://api.jqueryui.com/datepicker
$(document).ready(function() {
    if ($("[id$=category_savings_goal_date]").length) {
        loadDatePicker("[id$=category_savings_goal_date]");
    } else if ($("[id$=entry_entry_date]").length) {
        loadDatePicker("[id$=entry_entry_date]");
    }
});

function loadDatePicker(id) {
    $.getScript('https://code.jquery.com/jquery-1.10.2.js');
    $.getScript('https://code.jquery.com/ui/1.11.0/jquery-ui.js', function() {
        $(id).datepicker( {
            dateFormat: 'm/d/yy',
            changeMonth: true,
            changeYear: true,
            showOtherMonths: true
        });
    });
}
