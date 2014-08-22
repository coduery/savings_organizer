// jQuery function to display an account categories pie chart on Welcome page
$(document).ready(function() {
    if ($('#piechart').length) {
        var accountTotal = $('#piechart').data('account_total');
        if (accountTotal > 0) {
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

            var chartTitle = document.createElementNS(svgns, "text");
            chartTitle.setAttribute("x", "4");
            chartTitle.setAttribute("y", "25");
            chartTitle.setAttribute("style", "font-size: medium; font-weight:bold;");
            chartTitle.appendChild(document.createTextNode("Category Savings Percentage Chart"));
            chart.appendChild(chartTitle);

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

            $('#piechart').append(chart);
        }
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
});

// JavaScript function for updating a user's savings account name
function updateUser(accountName, accountNameIdMapping) {
    var accountNameIdHash = JSON.parse(accountNameIdMapping);
    var updateButtonChecked = false;
    for (var key in accountNameIdHash) {
        if (accountNameIdHash.hasOwnProperty(key)) {
            var accountNameId = "account-name-" + accountNameIdHash[key].toString();
            var updateButtonId = "update-" + accountNameIdHash[key].toString();
            var deleteButtonId = "delete-" + accountNameIdHash[key].toString();
            var accountNameIdHidden = "account-name-" + accountNameIdHash[key].toString() + "-hidden";
            var saveButtonId = "save-update-" + accountNameIdHash[key].toString();
            var cancelButtonId = "cancel-update-" + accountNameIdHash[key].toString();

            if (!updateButtonChecked) {
                var updateButtonEnabled = $("#update-" + accountNameIdHash[accountName].toString()).parent().css('display').toString();
                updateButtonChecked = true;
            }
            if (key != accountName) {
                if (updateButtonEnabled != "none") {
                    document.getElementById(updateButtonId).disabled=true;
                    document.getElementById(deleteButtonId).disabled=true;
                } else {
                    document.getElementById(updateButtonId).disabled=false;
                    document.getElementById(deleteButtonId).disabled=false;
                }
            } else if (key == accountName) {
                if (updateButtonEnabled != "none") {
                    var width = document.getElementById(accountNameId).clientWidth;
                    document.getElementById(accountNameId).style.display="none";
                    document.getElementById(updateButtonId).parentNode.style.display="none";
                    document.getElementById(deleteButtonId).parentNode.style.display="none";
                    document.getElementById(accountNameIdHidden).getElementsByTagName("input")[0].style.width = width.toString() + "px";
                    document.getElementById(accountNameIdHidden).style.display="table-cell";
                    document.getElementById(saveButtonId).parentNode.style.display="table-cell";
                    document.getElementById(cancelButtonId).parentNode.style.display="table-cell";
                } else {
                    document.getElementById(accountNameId).style.display="table-cell";
                    document.getElementById(updateButtonId).parentNode.style.display="table-cell";
                    document.getElementById(deleteButtonId).parentNode.style.display="table-cell";
                    document.getElementById(accountNameIdHidden).style.display="none";
                    document.getElementById(saveButtonId).parentNode.style.display="none";
                    document.getElementById(cancelButtonId).parentNode.style.display="none";
                }
            }
        }
    }
}

// JavaScript function for use in changing a user's email address
function changeUserEmail() {
    var changeEmailDiv = document.getElementById("change-email-div");
    if (changeEmailDiv.className == "hidden_class") {
        document.getElementById("change-email-div").className = "";
        hideManageUserButtons();
    } else {
        document.getElementById("change-email-div").className = "hidden_class";
        showManageUserButtons();
    }
}


// JavaScript function for use in deleting a user's account
function deleteUserAccount() {
    var deleteUserDiv = document.getElementById("delete-user-div");
    if (deleteUserDiv.className == "hidden_class") {
        document.getElementById("delete-user-div").className = "";
        hideManageUserButtons();
    } else {
        document.getElementById("delete-user-div").className = "hidden_class";
        showManageUserButtons();
    }
}

function hideManageUserButtons() {
    document.getElementById("user-manage-buttons").className = "hidden_class";
    document.getElementById("confirm_message").className = "hidden_class";
    h3Elements = document.getElementsByTagName("h3");
    if (h3Elements.length > 0) {
      h3Elements[0].parentNode.removeChild(h3Elements[0]);
    }
}

function showManageUserButtons() {
    document.getElementById("user-manage-buttons").className = "";
    document.getElementById("confirm_message").className = "";
}
