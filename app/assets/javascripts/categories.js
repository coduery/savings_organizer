// jQuery Function to draw categories line chart with Google Charts
// See https://google-developers.appspot.com/chart/interactive/docs/gallery/linechart
$(document).ready(function() {
    if ($('#categories_linechart').length) {
        $.getScript('https://www.google.com/jsapi', function() {
            var categoryDatesCumValues = $('#categories_linechart').data('category-entries-dates-cumulative-amounts');
            var categoryName = $('#categories_linechart').data('category-name');

            var chartData = [];
            chartData[0] = categoryDatesCumValues[0];
            var i = 1;
            for (j = 1; j < categoryDatesCumValues.length; j++) {
                var dateString = categoryDatesCumValues[j][0];
                var dateComponents = dateString.split("/");
                var date = new Date(dateComponents[2], (dateComponents[0] - 1), dateComponents[1]);
                categoryDatesCumValues[j][0] = date;
                if (j == 1) {
                    chartData[1] = categoryDatesCumValues[1];
                } else {
                    chartData[i] = [categoryDatesCumValues[j][0], categoryDatesCumValues[j - 1][1]];
                    chartData[++i] = categoryDatesCumValues[j];
                }
                i++;
            }

            google.load("visualization", "1", {packages:["corechart"], "callback":
                function drawChart() {
                    var data = google.visualization.arrayToDataTable(chartData);

                    var options = {
                        chartArea: {left: '15%', top: '15%', width: '80%', height: '70%'},
                        title: categoryName + ' Savings History',
                        titleTextStyle: {color: 'Arial', fontSize: 16},
                        vAxis: {format: '$ #,###', title: 'Total Amount', baseline: 0, gridlines: {color: '#A8A8A8'}, titleTextStyle: {italic: false}},
                        hAxis: {format: 'M/d/y', title: "Date", gridlines: {color: '#A8A8A8'}, titleTextStyle: {italic: false}},
                        legend: 'none',
                        pointSize: 0,
                        series: {0: {color: 'green'}}
                    };
    
                    var chart = new google.visualization.LineChart(document.getElementById('categories_linechart'));
                    chart.draw(data, options);
               }
           });
        });
    }
});


function updateCategory(categoryEntryId, categoryEntryIds) {
    var entryIds = categoryEntryIds.substring(1, categoryEntryIds.length - 1).split(/,/g);
    var updateButtonChecked = false;

    for (var i in entryIds) {
        if (entryIds.hasOwnProperty(i)) {
            var entryDateId = "entry-date-" + entryIds[i];
            var entryAmountId = "entry-amount-" + entryIds[i];
            var updateButtonId = "update-" + entryIds[i];
            var deleteButtonId = "delete-" + entryIds[i];
            var entryDateIdHidden = "entry-date-" + entryIds[i] + "-hidden";
            var entryAmountIdHidden = "entry-amount-" + entryIds[i] + "-hidden";
            var saveButtonId = "save-update-" + entryIds[i];
            var cancelButtonId = "cancel-update-" + entryIds[i];

            if (!updateButtonChecked) {
                var updateButtonEnabled = $("#update-" + categoryEntryId).parent().css('display');
                updateButtonChecked = true;
            }

            if (entryIds[i] != categoryEntryId) {
                if (updateButtonEnabled != "none") {
                    document.getElementById(updateButtonId).disabled=true;
                    document.getElementById(deleteButtonId).disabled=true;
                } else {
                    document.getElementById(updateButtonId).disabled=false;
                    document.getElementById(deleteButtonId).disabled=false;
                }
            } else if (entryIds[i] == categoryEntryId) {
                if (updateButtonEnabled != "none") {
                    document.getElementById(entryDateId).style.display="none";
                    document.getElementById(entryAmountId).style.display="none";
                    document.getElementById(updateButtonId).parentNode.style.display="none";
                    document.getElementById(deleteButtonId).parentNode.style.display="none";
                    document.getElementById(entryDateIdHidden).style.display="table-cell";
                    document.getElementById(entryAmountIdHidden).style.display="table-cell";
                    document.getElementById(saveButtonId).parentNode.style.display="table-cell";
                    document.getElementById(cancelButtonId).parentNode.style.display="table-cell";
                } else {
                    document.getElementById(entryDateId).style.display="table-cell";
                    document.getElementById(entryAmountId).style.display="table-cell";
                    document.getElementById(updateButtonId).parentNode.style.display="table-cell";
                    document.getElementById(deleteButtonId).parentNode.style.display="table-cell";
                    document.getElementById(entryDateIdHidden).style.display="none";
                    document.getElementById(entryAmountIdHidden).style.display="none";
                    document.getElementById(saveButtonId).parentNode.style.display="none";
                    document.getElementById(cancelButtonId).parentNode.style.display="none";
                }
            }
        }
    }
}
