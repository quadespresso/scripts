// check if the cell value contains certain sctring and color cell accordingly

function onEdit() {
  var sheet = SpreadsheetApp.getActiveSheet();
  var rows = sheet.getDataRange();
  var numRows = rows.getNumRows();
  var values = rows.getValues();
  
  var cellvalue = new String( sheet.getActiveCell().getValue() );
  Logger.log( cellvalue );
  if ( cellvalue.match( 'failed' ) ) {
    sheet.getActiveCell().setFontColor('red');
  }
  else if ( cellvalue.match( 'passed' ) ) {
    sheet.getActiveCell().setFontColor('green');
  }
  else {
    sheet.getActiveCell().setFontColor('black');
  }
};

// zibra stripe [ =MOD(ROW(A2),2) < 1 ]
