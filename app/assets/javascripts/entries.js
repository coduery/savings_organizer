// JavaScript funcntion to dyanmically add savings entries
function addEntries(categoryNames) {
  
  var total = new Number(0);
  var entryAmount;

  for (var i = 0; i < categoryNames.length; i++) {
    var categoryName = categoryNames[i];
    categoryName = "entry_" + categoryName;
    entryAmount = document.getElementById(categoryName).value;
    if (isNaN(entryAmount)) {
      alert("\"" + entryAmount + "\" is not a valid number entry!");
      document.getElementById(categoryName).value = "";
      break;
    } else if (entryAmount.indexOf(".") != -1 && (entryAmount.length - entryAmount.indexOf(".") > 3 )) {
      alert("Entry cannot be more than two decimal places!");
      document.getElementById(categoryName).value = "";
      break;
    } else {
      entryAmount = new Number(entryAmount);
      total += entryAmount;
    }
  }
    
  total = total.toFixed(2); 
  document.getElementById("entry_total").innerHTML = total;
}

// JavaScript funcntion to validate deduct savings entries
function validateEntry() {
  var entryAmount;
  entryAmount = document.getElementById("entry_entry_amount").value;
  if (isNaN(entryAmount)) {
    alert("\"" + entryAmount + "\" is not a valid number entry. \n\nPlease enter a positive number!");
    document.getElementById("entry_entry_amount").value = "";
  } else if (entryAmount.indexOf(".") != -1 && (entryAmount.length - entryAmount.indexOf(".") > 3 )) {
    alert("Entry cannot be more than two decimal places!");
    document.getElementById("entry_entry_amount").value = "";
  }
}

// jQuery function to adjust the size the Savings Entries Table
$(document).ready(function() {
  var numberCategories = new Number($('#entries_table').data('number_categories'));
  var tableWidth;
  if (numberCategories < 4) {
    tableWidth = 214 + 106 * numberCategories;
  } else {
    tableWidth = 638;
  }
  $('#entries_table').css( "width", tableWidth.toString() + "px" );
});

// jQuery function to display an account categories pie chart on Welcome page
$(document).ready(function(){
  var accountTotal = $('#piechart').data('account_total');
  var categoryNameAmountArray = $('#piechart').data('categories-saved-amount-array');
  
  var categoryNamePercentageMap = {};
  for (var i = 0; i < categoryNameAmountArray.length; i++) {
    categoryNamePercentageMap[categoryNameAmountArray[i][0]] = categoryNameAmountArray[i][1] / accountTotal;
  }
  
  var svgns = "http://www.w3.org/2000/svg";
  var chart = document.createElementNS(svgns, "svg");
  chart.setAttribute("width", "500");
  chart.setAttribute("height", "350");
  chart.setAttribute("viewBox", "0 0 500 350");
  var chartCenterXPosition = 225;
  var chartCenterYPosition = 175;
  var chartRadius = 100;
  var sliceAngleDegrees = 0.0;
  var firstSliceAngleDegrees = (categoryNameAmountArray[0][1] / accountTotal) * 360;
  var startAngleDegrees = 100.0 - firstSliceAngleDegrees / 2;  
  var startAngleRadians = 0.0;
  var endArcXPosition = 0.0;
  var endArcYPosition = 0.0;
  var usedColors = [];  
  
  var endRadialLineXPosition = chartCenterXPosition - Math.sin(degreesToRadians(startAngleDegrees)) * chartRadius;
  var endRadialLineYPosition = chartCenterYPosition + Math.cos(degreesToRadians(startAngleDegrees)) * chartRadius;
  
  var beginLeaderXPosition = 0.0;  
  var beginLeaderYPosition = 0.0;
  var middleLeaderXPosition = 0.0;
  var middleLeaderYPosition = 0.0;
  var endLeaderXPosition = 0.0;
  var textXPosition = 0.0;
  var textYPosition = 0.0;
  var textAnchor;
  var middleSliceAngleRadians = 0.0;
  
  // Colors from http://www.december.com/html/spec/colorsvg.html
  var colors = ["burlywood", "cadetblue", "chartreuse", "chocolate", "coral", "crimson", "cyan", 
    "darkgray", "darkkhaki", "darkseagreen", "dodgerblue", "fuchsia", "greenyellow", "lightgreen", 
    "lightskyblue", "mediumpurple", "orange", "orangered", "orchid", "springgreen", "yellow"];
    
  if (accountTotal > 0) {
    var chartTitle = document.createElementNS(svgns, "text");
    chartTitle.setAttribute("x", "4");
    chartTitle.setAttribute("y", "25");
    chartTitle.setAttribute("style", "font-size: medium; font-weight:bold;");
    chartTitle.appendChild(document.createTextNode("Category Savings Percentage Chart"));
    chart.appendChild(chartTitle);
  }
    
  for (var k in categoryNamePercentageMap) {     
    sliceAngleDegrees = categoryNamePercentageMap[k] * 360;
    startAngleDegrees += sliceAngleDegrees;
    startAngleRadians = degreesToRadians(startAngleDegrees);
    endArcXPosition = chartCenterXPosition - Math.sin(startAngleRadians) * chartRadius;
    endArcYPosition = chartCenterYPosition + Math.cos(startAngleRadians) * chartRadius;     
    drawPieSlice();
    endRadialLineXPosition = endArcXPosition;
    endRadialLineYPosition = endArcYPosition;
    
    middleSliceAngleRadians = degreesToRadians(startAngleDegrees - sliceAngleDegrees / 2);
    beginLeaderXPosition = chartCenterXPosition - Math.sin(middleSliceAngleRadians) * (chartRadius + 5);
    beginLeaderYPosition = chartCenterYPosition + Math.cos(middleSliceAngleRadians) * (chartRadius + 5);
    middleLeaderXPosition = chartCenterXPosition - Math.sin(middleSliceAngleRadians) * (chartRadius + 15);
    middleLeaderYPosition = chartCenterYPosition + Math.cos(middleSliceAngleRadians) * (chartRadius + 15);
    if (((startAngleDegrees - sliceAngleDegrees / 2) % 360) <= 180) {
      endLeaderXPosition = middleLeaderXPosition - 10;
      textXPosition = endLeaderXPosition - 3;
      textAnchor = "end";
    } else {
      endLeaderXPosition = middleLeaderXPosition + 10;
      textXPosition = endLeaderXPosition + 3;
      textAnchor = "start";
    }
    textYPosition = middleLeaderYPosition - 4;
    drawSliceLeader(k, categoryNamePercentageMap[k]);    
  }
  
  function degreesToRadians(degrees) {
    return degrees * Math.PI / 180;
  }
  
  function drawPieSlice() {
    if (sliceAngleDegrees < 360) {
      var path = document.createElementNS(svgns, "path");
      var arcFlags;
      if (sliceAngleDegrees < 180) {
        arcFlags = " 0 1 ";
      } else {
        arcFlags = " 1 1 ";
      }
      var d = "M" + chartCenterXPosition + " " + chartCenterYPosition +
              " L" + endRadialLineXPosition + " " + endRadialLineYPosition +
              " A" + chartRadius + " " + chartRadius + " 0" + arcFlags + 
              endArcXPosition + " " + endArcYPosition + " Z";
              
      path.setAttribute("d", d);
      
      if (usedColors.length < colors.length) {
        do {
          var i = Math.floor(Math.random() * colors.length);
        } while (usedColors.indexOf(colors[i]) != -1);
      } else {
        var i = Math.floor(Math.random() * colors.length);
      }
      usedColors.push(colors[i]);
      
      path.setAttribute("fill", colors[i]);
      path.setAttribute("stroke", "black"); 
      path.setAttribute("stroke-width", "1"); 
      chart.appendChild(path); 
    } else if (accountTotal > 0) {
      var circle = document.createElementNS(svgns, "circle");
      circle.setAttribute("cx", chartCenterXPosition);
      circle.setAttribute("cy", chartCenterYPosition);
      circle.setAttribute("r", chartRadius);
      circle.setAttribute("fill", colors[0]);
      circle.setAttribute("stroke", "black"); 
      circle.setAttribute("stroke-width", "1"); 
      chart.appendChild(circle); 
    }
  }

  function drawSliceLeader(categoryName, categoryPercentage) {   
    var categoryPercentage = (categoryPercentage * 100).toFixed(1);
    var polyline = document.createElementNS(svgns, "polyline");
    var points = beginLeaderXPosition + "," + beginLeaderYPosition + " " +
                 middleLeaderXPosition + "," + middleLeaderYPosition + " " +
                 endLeaderXPosition + "," + middleLeaderYPosition;  
        
    polyline.setAttribute("points", points);
    polyline.setAttribute("fill", "none");
    polyline.setAttribute("stroke", "black"); 
    polyline.setAttribute("stroke-width", "1");     
    chart.appendChild(polyline); 
    
    var textCategory = document.createElementNS(svgns, "text");
    textCategory.setAttribute("x", textXPosition);
    textCategory.setAttribute("y", textYPosition);
    textCategory.setAttribute("text-anchor", textAnchor);
    if (sliceAngleDegrees != 0) { 
      textCategory.appendChild(document.createTextNode(categoryName));
    } else {
      textCategory.appendChild(document.createTextNode("Others"));
    }
    chart.appendChild(textCategory); 
    
    var textPercentage = document.createElementNS(svgns, "text");
    textPercentage.setAttribute("x", textXPosition);
    textPercentage.setAttribute("y", textYPosition + 15);
    textPercentage.setAttribute("text-anchor", textAnchor);
    textPercentage.appendChild(document.createTextNode(categoryPercentage + " %"));
    chart.appendChild(textPercentage);
  }
  
  $("#piechart").append(chart);
}); 