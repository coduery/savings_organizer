// JavaScript function to dyanmically add savings entries
function addEntries(categoryNames) {

  var total = new Number(0);
  var entryAmount;
  var categoryId;

  for (var i = 0; i < categoryNames.length; i++) {
    categoryId = "entry_" + categoryNames[i].replace(/ /g, "_") + "_entry_amount";
    entryAmount = document.getElementById(categoryId).value;
    if (isNaN(entryAmount)) {
      alert("\"" + entryAmount + "\" is not a valid number entry!");
      document.getElementById(categoryId).value = "";
      break;
    } else if (entryAmount.indexOf(".") != -1 && (entryAmount.length - entryAmount.indexOf(".") > 3 )) {
      alert("Entry cannot be more than two decimal places!");
      document.getElementById(categoryId).value = "";
      break;
    } else {
      entryAmount = new Number(entryAmount);
      total += entryAmount;
    }
  }

  total = total.toFixed(2);
  document.getElementById("entry_total").innerHTML = total;
}

// JavaScript function to validate deduct savings entries
function validateEntry(categoryName) {
  var categoryId = "entry_" + categoryName + "_entry_amount";
  var entryAmount = document.getElementById(categoryId).value;
  if (isNaN(entryAmount)) {
    alert("\"" + entryAmount + "\" is not a valid number entry. \n\nPlease enter a positive number!");
    document.getElementById(categoryId).value = "";
  } else if (entryAmount.indexOf(".") != -1 && (entryAmount.length - entryAmount.indexOf(".") > 3 )) {
    alert("Entry cannot be more than two decimal places!");
    document.getElementById(categoryId).value = "";
  }
}

// jQuery function to adjust the size the Savings Entries Table
$(document).ready(function() {
  var numberCategories = new Number($('#data_table').data('number_categories'));
  var tableWidth;
  if (numberCategories < 4) {
    tableWidth = 214 + 106 * numberCategories;
  } else {
    tableWidth = 638;
  }
  $('#data_table').css( "width", tableWidth.toString() + "px" );
});

// jQuery Function to draw categories line chart with Google Charts
// See https://google-developers.appspot.com/chart/interactive/docs/gallery/linechart
$(document).ready(function() {
    $.getScript('https://www.google.com/jsapi', function() {
        var accountConsolidatedEntries = $('#linechart').data('consolidated-entries');
        var accountName = $('#linechart').data('account-name');
        var categoryNames = $('#linechart').data('category-names');

        var tempChartData = [["Date"].concat(categoryNames.slice(0, categoryNames.length))];
        var entryAmount = null;
        var entryArray = null;
        var i = null;
        for (i = 0; i < accountConsolidatedEntries.length; i++) {
            entryArray = [];

            var dateString = accountConsolidatedEntries[i][0];
            var dateComponents = dateString.split("/");
            var date = new Date(dateComponents[2], (dateComponents[0] - 1), dateComponents[1]);
            accountConsolidatedEntries[i][0] = date;

            for (j = 0; j < categoryNames.length + 1; j++) {
                if (j == 0) {
                    entryArray[j] = accountConsolidatedEntries[i][j];
                } else {
                    entryAmount = accountConsolidatedEntries[i][j];
                    if (i > 0) {
                        entryArray[j] = tempChartData[i][j] + entryAmount;
                    } else {
                        entryArray[j] = entryAmount;
                    }
                }
            }
            tempChartData[i + 1] = entryArray;
        }

        var chartData = [];
        chartData[0] = tempChartData[0];
        chartData[1] = tempChartData[1];
        var totalChartData = [];
        i = 2;
        for (j = 2; j < tempChartData.length; j++) {
            for (k = 0; k < categoryNames.length; k++) {
                totalChartData[k] = tempChartData[j - 1][k + 1];
            }
            chartData[i] = [tempChartData[j][0]].concat(totalChartData);
            chartData[++i] = tempChartData[j];
            i++;
        }
alert(chartData);
        google.load("visualization", "1", {packages:["corechart"], "callback": 
            function drawChart() {
                var data = google.visualization.arrayToDataTable(chartData);

                var options = {
                    chartArea: {left: '15%', top: '15%', width: '80%', height: '70%'},
                    title: accountName + ' Savings History',
                    titleTextStyle: {color: 'Arial', fontSize: 16},
                    vAxis: {format: '$ #,###', title: 'Total Amount', baseline: 0, gridlines: {color: '#A8A8A8'}, titleTextStyle: {italic: false}},
                    hAxis: {format: 'M/d/y', title: "Date", gridlines: {color: '#A8A8A8'}, titleTextStyle: {italic: false}},
                    legend: 'none',
                    pointSize: 0,
                    series: {0: {color: 'green'}}
                };

                var chart = new google.visualization.LineChart(document.getElementById('linechart'));
                chart.draw(data, options);
           }
       });

    });
});
