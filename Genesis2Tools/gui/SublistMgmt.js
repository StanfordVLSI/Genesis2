<script type="text/javascript"><!--

SublistMgmt = new function() {

  ///////////////////////////////////////////////////////////////////////
  // EXPORTED functions and data:                                      //
  ///////////////////////////////////////////////////////////////////////

  this.PopUp    = PopUp;
  this.PopDown  = PopDown;
  this.ButtonInCorrectScope  = ButtonInCorrectScope;
  this.CurDepth = CurDepth;

  this.FirstSublist = FirstSublist;
  this.PathName = PathName;         // E.g. "SPECIAL_DATA_MEM_OPS.13"
  this.Clear = Clear;

  ////////////////////////////////////////////////////////////////////////
  // PRIVATE functions and data:                                        //
  ////////////////////////////////////////////////////////////////////////
    
  var curdepth = 0;
  var firstsublist = new Array();  // E.g. firstsublist[0] is index of first sublist in first popup.
  var sublistpath = new Array();   // E.g. sublistpath[2] is path to 2nd-level popup (max 9?)
  //firstsublist[0] = 0;

  function CurDepth()     { return curdepth; }
  function FirstSublist() { return firstsublist[curdepth]; }

  // Does SublistMgmt need a "Sublists.ClearSublists()" equivalent?  Maybe called from "ClearSublists"?
  function Clear() {  curdepth = 0; firstsublist = []; firstsublist[0] = 0; }

  function PathName() {

      var path = sublistpath[1];
      for (var j=2; j <= curdepth; j++) { path += "." + sublistpath[j]; }

      //var dbg = 0; if (dbg) { alert("curdepth is " + curdepth); }
      //if (dbg) { alert("path[" + (j-1) + "] = " + path); }

      return path;
  }

  function PopUp(sublist) {
    curdepth++;

    var i = Sublists.GetNextSublistno(); firstsublist[curdepth] = i;

    sublistpath[curdepth] = Sublists.SublistName(sublist);
    //alert("building sublistpath[" + curdepth + "] = " + sublistpath[curdepth]);

    if (DBG) alert("ups we wents! curdepth " + curdepth + "; fsl " + firstsublist[curdepth]);

    // When someone pushes "Cancel" or "Submit", this remembers which subparm list to close.
    Remember(sublist); 
  }
    
  // PopDown is called from two places:
  //   ArrayEdit.rebuild_cursublist(), which does this: PopDown(); PopUp(); and
  //   Button_CancelSubmit.CancelFunc(), which does this: PopDown(); disappear()

  function PopDown() {
    var popped_sublist = Forget();

    if (curdepth <= 0) { alert("OOPS ERROR curdepth <= zero."); }

    if (DBG) alert("PopDown() before: curdepth is " + curdepth + " and fsl is " + firstsublist[curdepth]);

    Sublists.Truncate(firstsublist[curdepth]);

    curdepth--;

    if (DBG) alert("PopDown() after: curdepth is " + curdepth + " and fsl is " + firstsublist[curdepth]);

    return popped_sublist; // So we can make it disappear from the screen
  }

  function ButtonInCorrectScope(slnum) {

    // User pushed a button for sublist number "slnum" at TBD depth "sldepth"
    // If "sldepth" is not the same as "curdepth" the button is in the wrong submenu
    // and should not be processed.

    // "curdepth" is current level in the popup-menu stack;
    // i.e. curdepth 0 means no popups are open yet.

    // "firstsublist" array only valid at depth 1,2,...

    // Find sublistnum "i" of the first sublist at each level below curdepth;
    // if "i" > sublistnum of button pushed, the button is one below that level.  Get it?

    var i;
    for (i = 1; i <= curdepth; i++) {
      if (DBG) alert("fsl[" + i + "] = " + firstsublist[i]);
      if (firstsublist[i] > slnum) { break; }
    }
    var sldepth = i - 1;

    if (curdepth != sldepth) {
        alert("Oops.  I thought we were at depth " + curdepth +
              "\nbut the button you pushed is for sublist # " + slnum +
              "\nwhich appears to be at depth" + sldepth + " (check)" +
              "\nand thats...?  bad...?");
    }
    return (curdepth == sldepth);
  }


  ////////////////////////////////////////////////////////////////////////////////////////////////////
  // List of currently-open sublists at each depth; i.e. if there are three overlapping
  // popups on screen, their id's are in sublists_onscreen[0],[1] and [2] respectively.

  var sublists_onscreen = new Array();

  // TODO: go ahead and integrate forget(), remember() into appropriate routines above!

  // Remember which subparm list is currently active.
  // Called only from one place: SublistMgmt.PopUp(), when we're building the sublist
  // When someone pushes "Cancel" or "Submit", this func remembers which subparm list to close.
  function Remember(i) {
    var nestdepth = sublists_onscreen.push(i); // Note nestdepth is never used (yet).
  }

  // Forget() called only from SublistMgmt.PopDown()
  function Forget() { var i = sublists_onscreen.pop(); return i; }
  ////////////////////////////////////////////////////////////////////////////////////////////////////
}

//--></script>
