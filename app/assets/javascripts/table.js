// jQuery function to adjust the size the Savings Entries Table
$(document).ready(function() {
    if ($('#data_table').length) {
        var numberCategories = new Number($('#data_table').data('number_categories'));
        var tableWidth;
        if (numberCategories < 4) {
            tableWidth = 214 + 106 * numberCategories;
        } else {
            tableWidth = 638;
        }
        $('#data_table').css( "width", tableWidth.toString() + "px" );
    }
});