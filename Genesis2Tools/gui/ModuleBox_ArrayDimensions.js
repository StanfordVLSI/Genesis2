<script type="text/javascript"><!--

ModuleBox_ArrayDimensions = new function() {

  ///////////////////////////////////////////////////////////////////////
  // EXPORTED functions and data:                                      //
  ///////////////////////////////////////////////////////////////////////

  this.HowManyRows = HowManyRows;
  this.HowManyColumns = HowManyColumns;

  ///////////////////////////////////////////////////////////////////////
  // PRIVATE functions and data:                                       //
  ///////////////////////////////////////////////////////////////////////

  function HowManyRows   (nsubmods) { return GetDim(nsubmods, "rows"); }
  function HowManyColumns(nsubmods) { return GetDim(nsubmods, "columns"); }

//  // Test row/col functions for n=1 through 20
//  function TestRC() {
//    var r,c; for (var n=1; n<=20; n++) {
//      r=HowManyRows();
//      c=HowManyColumns();
//      alert("n=" + n + ": " + r + "x" + c);
//    }
//  }
  
  function GetDim(n, want) {
    var r, c;

    // If only one or two items, use a 2x1 array; three or four get a 2x2 and so on.

    //           1  2  3  4  5  6  7  8  9 10 11 12 
    var ncols = [2, 2, 2, 2, 3, 3, 3, 2, 3, 2, 3, 3];
    var nrows = [1, 1, 2, 2, 2, 2, 3, 4, 3, 5, 4, 4];

    if (n <= 12) {
      r = nrows[n-1]; c = ncols[n-1];     // Read from table, above.
    }
    else {                            // (13,14,15,16,17) => 4x4,4x4,4x4,4x4,4x5...4x100,4x101...
      c = 4;
      var i = parseInt(n); r = (parseInt((i+3)/4));
    }
    if (want == "rows") { return r; } else { return c; }
  }
}

//--></script>
