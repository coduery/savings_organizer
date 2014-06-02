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
