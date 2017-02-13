<script type="text/javascript"><!--

ParmBox = new function () {

    this.Draw = Draw;

    function Draw(m) {
        var rval; var isclone = ! (m.CloneOf == undefined);

        if (isclone) { rval = DrawCloneBox(m); } // Shortcut button.
        else         { rval = DrawParmBox(m);  } // Clickable list of parms.

        if (DBG) { alert("PB-DPB0:\n"+rval); }
        return rval;
    }
        
    function DrawCloneBox(m) {

        var boxtitle = "<b>Clone of: " + m.CloneOf.InstancePath + "<\/b>";
        
        // E.g. onclick='ModuleNavigator.GotoModule("top.DUT.p0")'

        var dqpath = '"' + m.CloneOf.InstancePath + '"'    ;
        var gotomod = 'ModuleNavigator.GotoModule(' + dqpath + ')';
        var onclick = "onclick='" + gotomod + "'";
        
        // Need backslashes below (e.g. "<\/b>") or html verification complains...
        var button_label = "Click to visit &nbsp;<b>" + m.CloneOf.InstancePath + "<\/b>";
        var button = "<button class=shortcut_button " + onclick + ">\n" + button_label + "<\/button>";
        
        var rval =
	    "<table class=parms style='height:100%;'>\n" +
	    "  <tr><td class=parmboxtitle>" + boxtitle +      "<\/td><\/tr>\n" + 

	    "  <tr><td class=parmboxparms id=scb_container>\n" +
            "    " + button + "\n" +
            "<\/td><\/tr>\n" +

	    "<\/table>";

        if (DBG9) { alert(rval); } return rval;
    }

  function DrawParmBox(m) {
    var immparmform = ParmBoxForm.Build(m, m.ImmutableParameters, "immutable");
    var parmform    = ParmBoxForm.Build(m, m.Parameters,           "mutable");

    var boxtitle    = "<b>Parameters for instance \"" + ModuleNavigator.curpathstring() + "\"<\/b>";

    var submitbutton =
      "<table width=100%><tr>\n" + 

    //"  <td width=50% height=0% style='text-align:center'><\/td>\n" +

      "  <td width=100% style='text-align:right'>\n" +
      "      <input type='button' id='changebutton' value='Submit changes'><\/input>\n" +
      "  <\/td>\n" + 

      "<\/tr><\/table>";

    var rval =
        "<table class=parms style='height:100%'>\n" +
        "  <tr><td class=parmboxtitle>" + boxtitle + "<\/td><\/tr>\n";

    if (parmform) rval +=
        "  <tr><td class=parmboxcaption>User-tweakable parameters:" + "<\/td><\/tr>\n" +
        "  <tr><td class=parmboxparms>"     + parmform + "<\/td><\/tr>\n";

    if (immparmform) rval +=
        "  <tr><td class=parmboxcaption><i>Immutable parameters:<\/i><\/td><\/tr>\n"+
        "  <tr><td class=parmboxparms style='height:100%;'>"  + immparmform + "<\/td><\/tr>\n";

    rval += "  <tr><td>" +  submitbutton + "<\/td><\/tr>\n";
    rval += "<\/table>";

    if (DBG9) { alert(rval); } return rval;
  }
}

//--></script>


