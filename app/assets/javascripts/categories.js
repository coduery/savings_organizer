// jQuery Function to draw categories line chart with Google Charts
// See https://google-developers.appspot.com/chart/interactive/docs/gallery/linechart
$(document).ready(function() {
    $.getScript('https://www.google.com/jsapi', function() {
        var categoryDatesCumValues = $('#linechart').data('category-entries-dates-cumulative-amounts');
        var categoryName = $('#linechart').data('category-name');

        var i;
        for (i = 1; i < categoryDatesCumValues.length; i++) {
            var dateString = categoryDatesCumValues[i][0];
            var dateComponents = dateString.split("/");
            var date = new Date(dateComponents[2], (dateComponents[0] - 1), dateComponents[1]);
            categoryDatesCumValues[i][0] = date;
        }

        var chartData = [];
        chartData[0] = categoryDatesCumValues[0];
        chartData[1] = categoryDatesCumValues[1];
        i = 2;
        for (j = 2; j < categoryDatesCumValues.length; j++) {
            chartData[i] = [categoryDatesCumValues[j][0], categoryDatesCumValues[j - 1][1]];
            chartData[++i] = categoryDatesCumValues[j];
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

                var chart = new google.visualization.LineChart(document.getElementById('linechart'));
                chart.draw(data, options);
           }
       });

    });
});
