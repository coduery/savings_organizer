function updateAccount(categoryName, categoryNameIdMapping) {
  var categoryNameIdHash = JSON.parse(categoryNameIdMapping);
  for (var key in categoryNameIdHash) {
    if (categoryNameIdHash.hasOwnProperty(key)) {
      var updateButtonId = "update-" + categoryNameIdHash[key].toString();
      var deleteButtonId = "delete-" + categoryNameIdHash[key].toString();
      if (key != categoryName) {
        document.getElementById(updateButtonId).disabled=true;
        document.getElementById(deleteButtonId).disabled=true;
      } else if (key == categoryName) {
        document.getElementById(updateButtonId).parentNode.style.display="none";
        document.getElementById(deleteButtonId).parentNode.style.display="none";
        var saveButtonId = "save-update-" + categoryNameIdHash[key].toString();
        var cancelButtonId = "cancel-update-" + categoryNameIdHash[key].toString();
        document.getElementById(saveButtonId).parentNode.style.display="table-cell";
        document.getElementById(cancelButtonId).parentNode.style.display="table-cell";
      }
    }
  }
}

function cancelUpdateAccount(categoryName, categoryNameIdMapping) {
  var categoryNameIdHash = JSON.parse(categoryNameIdMapping);
  for (var key in categoryNameIdHash) {
    if (categoryNameIdHash.hasOwnProperty(key)) {
      var updateButtonId = "update-" + categoryNameIdHash[key].toString();
      var deleteButtonId = "delete-" + categoryNameIdHash[key].toString();
      if (key != categoryName) {
        document.getElementById(updateButtonId).disabled=false;
        document.getElementById(deleteButtonId).disabled=false;
      } else if (key == categoryName) {
        document.getElementById(updateButtonId).parentNode.style.display="table-cell";
        document.getElementById(deleteButtonId).parentNode.style.display="table-cell";
        var saveButtonId = "save-update-" + categoryNameIdHash[key].toString();
        var cancelButtonId = "cancel-update-" + categoryNameIdHash[key].toString();
        document.getElementById(saveButtonId).parentNode.style.display="none";
        document.getElementById(cancelButtonId).parentNode.style.display="none";
      }
    }
  }
}
