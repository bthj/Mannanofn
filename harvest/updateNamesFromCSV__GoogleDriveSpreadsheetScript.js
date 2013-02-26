// Script for Google Drive Spreadsheet to update name metadata.

/**
 * Asks for a CSV file name, for each entry in the file searches for the name in the spreadsheet,
 * if the name is found the corresponding row is update, otherwise a new row is created.
 * @author bthj.is
*/
function updateFromCSV() {
  var fileName = Browser.inputBox("Sláðu inn nafn skrárinnar sem þú vilt nota til að uppfæra (t.d. names.csv):");
  var files = DocsList.getFiles();
  var csvFile = "";
  for( var i=0; i < files.length; i++ ) {
    if( files[i].getName() == fileName ) {
      csvFile = files[i].getContentAsString();
      break;
    }
  }
  if( csvFile ) {
  var csvData = CSVToArray(csvFile, ",");
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getActiveSheet();
  var sheetData = sheet.getDataRange().getValues();
  for( var i=0; i < csvData.length; i++ ) {
    var oneName = csvData[i][0];
    var oneNameIndex = findName( sheetData, oneName );
    var adding = false;
    if( ! oneNameIndex ) {
      oneNameIndex = sheet.getLastRow()+1;
      adding = true;
    }
    // countAsFirstName
    sheet.getRange(oneNameIndex, 11, 1, 1).setValue( csvData[i][4] );
    // countAsSecondName
    sheet.getRange(oneNameIndex, 12, 1, 1).setValue( csvData[i][5] );
    // dateModified
    sheet.getRange(oneNameIndex, 16, 1, 1).setValue( csvData[i][8] );
    if( adding ) {
      // dateAdded
      sheet.getRange(oneNameIndex, 15, 1, 1).setValue( csvData[i][7] );
      // name
      sheet.getRange(oneNameIndex, 1, 1, 1).setValue( csvData[i][0] );
      // gender
      sheet.getRange(oneNameIndex, 2, 1, 1).setValue( csvData[i][1] );
    }
  }
  } else {
    Browser.msgBox("Skráin " + fileName + " fannst ekki.");
  }

}

function findName(data, obj) {
  for (var i = 0; i < data.length; i++) {
    if (data[i][0] == obj) {
      return i+1;
    }
  }
  return null;
}

/**
 * Adds a custom menu to the active spreadsheet, containing a single menu item
 * for invoking the readRows() function specified above.
 * The onOpen() function, when defined, is automatically invoked whenever the
 * spreadsheet is opened.
 * For more information on using the Spreadsheet API, see
 * https://developers.google.com/apps-script/service_spreadsheet
 */
function onOpen() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet();
  sheet.addMenu("Uppfæra", [{name: "Uppfæra úr CSV skrá", functionName: "updateFromCSV"}]);
};





// http://www.bennadel.com/blog/1504-Ask-Ben-Parsing-CSV-Strings-With-Javascript-Exec-Regular-Expression-Command.htm
// This will parse a delimited string into an array of
// arrays. The default delimiter is the comma, but this
// can be overriden in the second argument.

function CSVToArray( strData, strDelimiter ){
  // Check to see if the delimiter is defined. If not,
  // then default to comma.
  strDelimiter = (strDelimiter || ",");

  // Create a regular expression to parse the CSV values.
  var objPattern = new RegExp(
    (
      // Delimiters.
      "(\\" + strDelimiter + "|\\r?\\n|\\r|^)" +

      // Quoted fields.
      "(?:\"([^\"]*(?:\"\"[^\"]*)*)\"|" +

      // Standard fields.
      "([^\"\\" + strDelimiter + "\\r\\n]*))"
    ),
    "gi"
  );


  // Create an array to hold our data. Give the array
  // a default empty first row.
  var arrData = [[]];

  // Create an array to hold our individual pattern
  // matching groups.
  var arrMatches = null;


  // Keep looping over the regular expression matches
  // until we can no longer find a match.
  while (arrMatches = objPattern.exec( strData )){

    // Get the delimiter that was found.
    var strMatchedDelimiter = arrMatches[ 1 ];

    // Check to see if the given delimiter has a length
    // (is not the start of string) and if it matches
    // field delimiter. If id does not, then we know
    // that this delimiter is a row delimiter.
    if (
      strMatchedDelimiter.length &&
      (strMatchedDelimiter != strDelimiter)
    ){

      // Since we have reached a new row of data,
      // add an empty row to our data array.
      arrData.push( [] );

    }


    // Now that we have our delimiter out of the way,
    // let's check to see which kind of value we
    // captured (quoted or unquoted).
    if (arrMatches[ 2 ]){

      // We found a quoted value. When we capture
      // this value, unescape any double quotes.
      var strMatchedValue = arrMatches[ 2 ].replace(
        new RegExp( "\"\"", "g" ),
        "\""
      );

    } else {

      // We found a non-quoted value.
      var strMatchedValue = arrMatches[ 3 ];

    }


    // Now that we have our value string, let's add
    // it to the data array.
    arrData[ arrData.length - 1 ].push( strMatchedValue );
  }

  // Return the parsed data.
  return( arrData );
}