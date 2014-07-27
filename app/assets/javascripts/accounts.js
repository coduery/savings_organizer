function updateAccount(categoryName, categoryNameIdMapping) {
  var categoryNameIdHash = JSON.parse(categoryNameIdMapping);
  var updateButtonChecked = false;

  for (var key in categoryNameIdHash) {
    if (categoryNameIdHash.hasOwnProperty(key)) {
      var categoryNameId = "category-name-" + categoryNameIdHash[key].toString();
      var savingsGoalId = "savings-goal-" + categoryNameIdHash[key].toString();
      var savingsGoalDateId = "savings-goal-date-" + categoryNameIdHash[key].toString();
      var updateButtonId = "update-" + categoryNameIdHash[key].toString();
      var deleteButtonId = "delete-" + categoryNameIdHash[key].toString();
      var categoryNameIdHidden = "category-name-" + categoryNameIdHash[key].toString() + "-hidden";
      var savingsGoalIdHidden = "savings-goal-" + categoryNameIdHash[key].toString() + "-hidden";
      var savingsGoalDateIdHidden = "savings-goal-date-" + categoryNameIdHash[key].toString() + "-hidden";
      var saveButtonId = "save-update-" + categoryNameIdHash[key].toString();
      var cancelButtonId = "cancel-update-" + categoryNameIdHash[key].toString();

      if (!updateButtonChecked) {
        var updateButtonEnabled = document.getElementById(updateButtonId).disabled;
        updateButtonChecked = true;
      }

      if (key != categoryName) {
        if (!updateButtonEnabled) {
          document.getElementById(updateButtonId).disabled=true;
          document.getElementById(deleteButtonId).disabled=true;
        } else {
          document.getElementById(updateButtonId).disabled=false;
          document.getElementById(deleteButtonId).disabled=false;
        }
      } else if (key == categoryName) {
        if (!updateButtonEnabled) {
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
