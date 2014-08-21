function updateAccount(categoryName, categoryNameIdMapping) {
    var categoryNameIdHash = JSON.parse(categoryNameIdMapping);
    var updateButtonChecked = false;

    for (var key in categoryNameIdHash) {
        if (categoryNameIdHash.hasOwnProperty(key)) {
            var categoryNameId = "category-name-" + categoryNameIdHash[key];
            var savingsGoalId = "savings-goal-" + categoryNameIdHash[key];
            var savingsGoalDateId = "savings-goal-date-" + categoryNameIdHash[key];
            var updateButtonId = "update-" + categoryNameIdHash[key];
            var deleteButtonId = "delete-" + categoryNameIdHash[key];
            var categoryNameIdHidden = "category-name-" + categoryNameIdHash[key] + "-hidden";
            var savingsGoalIdHidden = "savings-goal-" + categoryNameIdHash[key] + "-hidden";
            var savingsGoalDateIdHidden = "savings-goal-date-" + categoryNameIdHash[key] + "-hidden";
            var saveButtonId = "save-update-" + categoryNameIdHash[key];
            var cancelButtonId = "cancel-update-" + categoryNameIdHash[key];

            if (!updateButtonChecked) {
                var updateButtonEnabled = $("#update-" + categoryNameIdHash[categoryName]).parent().css('display');
                updateButtonChecked = true;
            }

            if (key != categoryName) {
                if (updateButtonEnabled != "none") {
                    document.getElementById(updateButtonId).disabled=true;
                    document.getElementById(deleteButtonId).disabled=true;
                } else {
                    document.getElementById(updateButtonId).disabled=false;
                    document.getElementById(deleteButtonId).disabled=false;
                }
            } else if (key == categoryName) {
                if (updateButtonEnabled != "none") {
                    document.getElementById(categoryNameId).style.display="none";
                    document.getElementById(savingsGoalId).style.display="none";
                    document.getElementById(savingsGoalDateId).style.display="none";
                    document.getElementById(updateButtonId).parentNode.style.display="none";
                    document.getElementById(deleteButtonId).parentNode.style.display="none";
                    document.getElementById(categoryNameIdHidden).style.display="table-cell";
                    document.getElementById(savingsGoalIdHidden).style.display="table-cell";
                    document.getElementById(savingsGoalDateIdHidden).style.display="table-cell";
                    document.getElementById(saveButtonId).parentNode.style.display="table-cell";
                    document.getElementById(cancelButtonId).parentNode.style.display="table-cell";
                } else {
                    document.getElementById(categoryNameId).style.display="table-cell";
                    document.getElementById(savingsGoalId).style.display="table-cell";
                    document.getElementById(savingsGoalDateId).style.display="table-cell";
                    document.getElementById(updateButtonId).parentNode.style.display="table-cell";
                    document.getElementById(deleteButtonId).parentNode.style.display="table-cell";
                    document.getElementById(categoryNameIdHidden).style.display="none";
                    document.getElementById(savingsGoalIdHidden).style.display="none";
                    document.getElementById(savingsGoalDateIdHidden).style.display="none";
                    document.getElementById(saveButtonId).parentNode.style.display="none";
                    document.getElementById(cancelButtonId).parentNode.style.display="none";
                }
            }
        }
    }
}
