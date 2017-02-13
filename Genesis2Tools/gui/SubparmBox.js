<script type="text/javascript"><!--

SubparmBox = new function () {

  ///////////////////////////////////////////////////////////////////////
  // EXPORTED functions and data:                                      //
  ///////////////////////////////////////////////////////////////////////

  // This will go to new module "SubparmBox.js"
  this.BuildPopUp = BuildPopUp;
  this.RebuildPopUp = RebuildPopUp;

  ////////////////////////////////////////////////////////////////////////
  // PRIVATE functions and data:                                        //
  ////////////////////////////////////////////////////////////////////////
    
  // Called twice: once from Button_Subparmlist
  // and once from SubparmBox.RebuildPopUp() below

  function BuildPopUp(i) {
    SublistMgmt.PopUp(i);
    var smbox = BuildSubparmBox(i);
    if (DBG9) { alert("SPB-BPU1:\n"+smbox); }
    return smbox;
  }

  function RebuildPopUp() {
    // Rebuild existing top-level popup, presumably because of an array insertion or deletion.

    ////////////////////////////////////////////////////////////////////////
    // Tear infrastructure of existing submenu<i> (but leave it on screen)

    var i = SublistMgmt.PopDown();
    var smid = "submenu" + i;                   // E.g. "submenu15"

    if (DBG9) { alert("Previous contents of " + smid + " =\n" +
                      document.getElementById(smid).innerHTML); }
    ////////////////////////////////////////////////////////////////////////
    // Build new submenu<i>
    var smbox = SubparmBox.BuildPopUp(i);
    if (DBG) { showpartial(smbox); }

    ////////////////////////////////////////////////////////////////////////
    // Replace existing submenu<i> with new submenu<i>
    if (DBG9) { alert("gonna rewrite " + ("submenu" + i)); }
    document.getElementById("submenu" + i).innerHTML = smbox;

    Button_SubparmList.ActivateAll("subparm" + i); // Activate sublist "expand" buttons in pop-up
  }

 function showpartial(s) {
     // Show some of the very long string "s" (so it fits on the screen)
     var l = s.length;
     alert("s=\n"
           + s.substring(0,1400) + "\n...\n"
           + s.substring(l-600,l-1)
           );
 }

  function BuildSubparmBox(i) {

    // Called when someone pushes a "click to expand" subparm button.
    // Builds a table containing the subparm fill-in form.

    var boxtitle    = SubparmTitlebar(i);

      var subparmform = NEW_ARR_EDIT_MODE ? Sublists.SubparmForm2(i) : Sublists.SubparmForm(i);

    var rval =
      "<table class=parms style='height:100%'>\n" +
      "  <tr><td class=parmboxtitle>\n\n" + boxtitle    + "\n  <\/td><\/tr>\n\n" +
      "  <tr><td class=parmboxparms>" + subparmform + "<\/td><\/tr>" + 
      "<\/table>";

    // Box over a box. TODO: Could try using dropshadow instead of white border.
    rval = "<table bgcolor=white><tr><td>" + rval + "<\/td><\/tr><\/table>";

    if (DBG) { alert("RVAL = " + rval); }

    return rval;
  }

  function SubparmTitlebar(i) { // Including "submit" and "cancel" buttons.

    var rval =
      "<table width=100%><tr>\n" +
      "  <td align=left style='color:white'><b><small>" + Sublists.SublistName(i) + "<\/b><\/small><\/td>\n" +
      "  <td align=right>\n" + 
      "    <table class=button id=submitsubparm" + i +
      "><tr><td><small>&nbsp;Submit&nbsp;<\/small><\/tr><\/td><\/table>\n" +
      "  <\/td><\/small>\n" +
      "  <td align=right>\n" + 
      "    <table class=button id=cancelsubparm" + i +
      "><tr><td><small>&nbsp;Cancel&nbsp;<\/small><\/tr><\/td><\/table>\n" +
      "  <\/td>\n" +
      "<\/tr><\/table>\n";

    if (DBG9) alert("SPB-TB1:\n"+rval);
    return rval;
  }
}

//--></script>
