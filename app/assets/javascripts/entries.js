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
  var numberCategories = new Number($('#entries_table').data('number_categories'));
  var tableWidth;
  if (numberCategories < 4) {
    tableWidth = 214 + 106 * numberCategories;
  } else {
    tableWidth = 638;
  }
  $('#entries_table').css( "width", tableWidth.toString() + "px" );
});
