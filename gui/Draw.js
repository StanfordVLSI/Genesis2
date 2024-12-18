<script type="text/javascript"><!--

Draw = new function () {


  ///////////////////////////////////////////////////////////////////////
  // EXPORTED functions and data:                                      //
  ///////////////////////////////////////////////////////////////////////

  this.Screen     = DrawScreen;

  ///////////////////////////////////////////////////////////////////////
  // PRIVATE functions and data:                                       //
  ///////////////////////////////////////////////////////////////////////

  // DrawScreen(top.subInstances.dut) => draw module top.subInstances.dut.
  function DrawScreen(m) {

    Sublists.ClearSublists(); // Is this the right place??

    var mods_table  = ModuleBox.Draw(m);
    var parms_table =   ParmBox.Draw(m);

    var layout =
      "<table id=layout class=layout><tr style='vertical-align:top'>\n" +
      "  <td>\n    " + mods_table + "\n  <\/td>\n" +
      "  <td style='height:100%;padding:0'>\n    "+ parms_table + "\n  <\/td>\n" +
      "<\/tr><\/table>";

    // Draw the screen.

    if (DBG) { alert(layout); }
    document.getElementById("mainbody" ).innerHTML = layout;

    // This is the only safe place to reset PENDING_PARMCHANGE;
    // because innerHTML assign (above) can trigger pending "onchange" event.
    PENDING_PARMCHANGE = false;    

    // Activate active elements: submodules and "up" button"
    Submodules.PowerOn(m);
    Button_SubparmList.ActivateAll("main");

    COMMENTRULE.style.display = SHOWCOMMENTS? "" : "none";
  }
}

//--></script>
